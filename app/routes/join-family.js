import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class JoinFamilyRoute extends Route {
  @service store;

  model(params) {
    return this.store.findRecord('family-invitation', params.token);
  }
}
