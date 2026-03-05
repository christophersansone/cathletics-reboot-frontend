import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class DashboardRoute extends Route {
  @service store;

  async model() {
    const adapter = this.store.adapterFor('application');
    const url = `${adapter.host}/${adapter.namespace}/dashboard`;
    const response = await adapter.ajax(url, 'GET');
    return { stats: response.data, org: this.modelFor('orgs.org') };
  }
}
