import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ActivityTypesIndexRoute extends Route {
  @service store;

  model() {
    return {
      org: this.modelFor('orgs.org'),
      activityTypes: this.store.query('activity-type', {}),
    };
  }
}
