import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class HomeRoute extends Route {
  @service store;

  async model() {
    const adapter = this.store.adapterFor('application');
    const url = `${adapter.host}/${adapter.namespace}/home`;
    const response = await adapter.ajax(url, 'GET');
    return response.data;
  }
}
