import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class OrgsOrgRoute extends Route {
  @service session;
  @service store;

  model(params) {
    return this.store.queryRecord('organization', { slug: params.org_slug });
  }

  afterModel(org) {
    this.session.setOrganization(org);
  }
}
