import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';

export default class OrgsOrgRoute extends Route {
  @service session;
  @service store;
  @service router;

  beforeModel() {
    if (!this.session.isAuthenticated) {
      this.router.transitionTo('login');
    }
  }

  model(params) {
    return this.store.queryRecord('organization', { slug: params.org_slug });
  }
}
