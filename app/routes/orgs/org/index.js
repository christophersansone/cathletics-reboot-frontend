import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';

export default class OrgsOrgIndexRoute extends Route {
  @service router;

  beforeModel() {
    this.router.transitionTo('orgs.org.dashboard');
  }
}
