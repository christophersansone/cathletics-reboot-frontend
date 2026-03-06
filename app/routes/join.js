import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class JoinRoute extends Route {
  @service store;

  model(params) {
    return this.store.queryRecord('organization', { slug: params.org_slug });
  }
}
