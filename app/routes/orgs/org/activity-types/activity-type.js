import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ActivityTypeRoute extends Route {
  @service store;

  model(params) {
    return this.store.findRecord('activity-type', params.activity_type_id);
  }

  breadcrumb(model) {
    return { title: model.name };
  }
}
