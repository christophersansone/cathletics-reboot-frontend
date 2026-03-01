import Service, { service } from '@ember/service';
import { getOwner } from '@ember/application';
import { TrackedObject } from 'tracked-built-ins';

/*
  This service addresses two long-standing concerns with Ember Data:

  1. Model attributes and relationships still require `.set()` rather than using tracked properties.

  2. Because there is only ever one instance of a model, directly making changes to the model can
     wind up pollinating a dirty state to the rest of the app, which then requires defensive code
     to always clean up the dirty state, e.g. when navigating away from the editor.  Because methods
     like `model.save()` require the model to have dirty state, models having unsaved dirty state
     has been a necessity.

  This service addresses both of these issues with a simple approach: it unlocks the ability to
  send the create / update / delete methods to the server without making direct changes to the model.
  It makes use of the adapters, serializers, and transforms to send the correct payload to the correct
  API endpoint, just as the model's built-in methods would.  It then loads the response payload into
  the store, to reflect the changes that just took place on the server.

  This approach follows the Ember reactivity model much more closely, with the "Data Down, Actions Up"
  paradigm.  Rather than mutating the model with two-way bindings, it sends an "action up" to the server
  to make the changes.  The server then sends the response "data down" into the store, thereby updating
  the models, and the rest of the app can then react to the changes.  If the request fails, the promise
  is rejected, there is no dirty state, and therefore there are no changes to rollback.

  With this approach, the store and models can be considered immutable, and therefore always maintain
  a pristine state in the store.  The store then is always a reflection of the server's data as of
  the time it was last requested.

  And because the models are read-only, there is no need to use `model.set()`.  Instead, one can create
  their own data structure with tracked properties, and then use this service to apply those changes.
*/

export default class Atomic extends Service {
  @service store;

  async createModel(type, properties) {
    const payload = this.buildCreatePayload(type, properties);
    const response = await this.adapterCreate(type, payload);
    this.store.pushPayload(response);
    const id = response.data.id;
    const model = this.store.peekRecord(type, id);
    return model;
  }

  async updateModel(model, properties) {
    const type = this.typeFor(model);
    const payload = this.buildFullUpdatePayload(model, properties);
    const response = await this.adapterUpdate(type, model.id, payload);
    this.store.pushPayload(response);
    return model;
  }

  async patchModel(model, properties) {
    const type = this.typeFor(model);
    const payload = this.buildPartialUpdatePayload(model, properties);
    const response = await this.adapterUpdate(type, model.id, payload);
    this.store.pushPayload(response);
    return model;
  }

  async destroyModel(model) {
    const type = this.typeFor(model);
    await this.adapterDelete(type, model.id);
    model.unloadRecord();
  }

  buildCreatePayload(type, properties) {
    let model = this.store.createRecord(type, properties);
    try {
      return model.serialize();
    } finally {
      model.unloadRecord();
    }
  }

  buildFullUpdatePayload(model, properties) {
    const type = this.typeFor(model);
    let result = model.serialize();
    const delta = this.serializeDelta(type, model.id, properties);
    if (delta.data.attributes) {
      for (const attr in delta.data.attributes) {
        result.data.attributes[attr] = delta.data.attributes[attr];
      }
    }
    if (delta.data.relationships) {
      for (const rel in delta.data.relationships) {
        result.data.relationships[rel] = delta.data.relationships[rel];
      }
    }
    return result;
  }

  buildPartialUpdatePayload(model, properties) {
    const type = this.typeFor(model);
    return this.serializeDelta(type, model.id, properties);
  }

  async adapterCreate(type, payload) {
    const adapter = this.store.adapterFor(type);
    const url = adapter.urlForCreateRecord(type);
    return await adapter.ajax(url, 'POST', { data: payload });
  }

  async adapterUpdate(type, id, payload) {
    const adapter = this.store.adapterFor(type);
    const url = adapter.urlForUpdateRecord(id, type);
    return await adapter.ajax(url, 'PUT', { data: payload });
  }

  async adapterDelete(type, id) {
    const adapter = this.store.adapterFor(type);
    const url = adapter.urlForDeleteRecord(id, type);
    return await adapter.ajax(url, 'DELETE');
  }

  typeFor(model) {
    return model.constructor.modelName;
  }

  // returns a serialization of the specified model type, ID, and only the listed properties
  serializeDelta(type, id, properties) {
    const serializer = this.store.serializerFor(type);
    const model = this.store.createRecord(type, properties);
    try {
      let serialized = model.serialize();
      if (id) {
        serialized.data.id = id;
      }
      const updatedProperties = Object.keys(properties);
      if (serialized.data.attributes) {
        model.eachAttribute((attrName) => {
          if (!updatedProperties.includes(attrName)) {
            const serializedKey = serializer.keyForAttribute ? serializer.keyForAttribute(attrName, 'serialize') : attrName;
            delete serialized.data.attributes[serializedKey];
          }
        });
      }
      if (serialized.data.relationships) {
        model.eachRelationship((attrName) => {
          if (!updatedProperties.includes(attrName)) {
            const serializedKey = serializer.keyForRelationship ? serializer.keyForRelationship(attrName, 'serialize') : attrName;
            delete serialized.data.relationships[serializedKey];
          }
        });
      }
      return serialized;
    } finally {
      model.unloadRecord();
    }
  }

  // Returns a tracked primitive object with all the attributes and (belongs to) relationships
  // of the model.  This can then be used with `createModel` and `updateModel`.
  // Note: even though this method is synchronous, any unfetched belongsTo relationships
  // will be fetched and asynchronously populated on the result.  Best practice is to load these
  // relationships prior to calling this to avoid any confusion, but it is handled well otherwise.
  // Most of the time, belongsTo relationships are included in the response payload for the resource,
  // so it is probably somewhat rare for these to be loaded asynchronously here anyway.
  trackedModel(model) {
    let attributes = {};
    model.eachAttribute((a) => attributes[a] = this.cloneAttribute(model, a));
    let result = new TrackedObject(attributes);
    model.constructor.relationshipNames.belongsTo.forEach((r) => {
      // assign what we can synchronously
      const value = model.belongsTo(r).value();
      result[r] = value;
      if (!value) {
        // the relationship may be null or it may just not be loaded --
        // asynchronously load (if not already loaded) and set the value
        model.belongsTo(r).load().then((v) => result[r] = v);
      }
    });
    return result;
  }

  // for new records
  newTrackedModel(type, properties = {}) {
    const model = this.store.createRecord(type, properties);
    try {
      let result = {};
      model.eachAttribute((a) => result[a] = this.cloneAttribute(model, a));
      const relationshipsToClone = model.constructor.relationshipNames.belongsTo;
      relationshipsToClone.forEach((r) => result[r] = model.belongsTo(r).value());
      return new TrackedObject(result);
    } finally {
      model.unloadRecord();
    }
  }

  transforms = {};

  transformFor(type) {
    if (type) {
      if (!this.transforms[type]) {
        this.transforms[type] = getOwner(this).lookup(`transform:${type}`);
      }
      return this.transforms[type];
    }
  }

  cloneAttribute(model, attributeName) {
    const attributeType = model.constructor.attributes.get(attributeName).type;
    const value = model[attributeName];
    // any falsey value is a primitive -- just return it as is
    if (!value) {
      return value;
    }

    const transformClass = this.transformFor(attributeType);
    if (transformClass) {
      return transformClass.deserialize(transformClass.serialize(value));
    } else {
      // no type defined, which is mostly common for objects -- clone it by serializing to JSON
      return JSON.parse(JSON.stringify(value));
    }
  }
}
