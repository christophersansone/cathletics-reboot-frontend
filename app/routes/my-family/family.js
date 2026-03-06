import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class MyFamilyFamilyRoute extends Route {
  @service store;

  async model({ family_id }) {
    return this.store.findRecord('family', family_id, { reload: true });
  }
}
