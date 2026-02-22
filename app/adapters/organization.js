import ApplicationAdapter from './application';

export default class OrganizationAdapter extends ApplicationAdapter {
  queryRecord(store, type, query) {
    let url = `${this.buildURL(type.modelName)}/${query.slug}`;
    return this.ajax(url, 'GET');
  }
}
