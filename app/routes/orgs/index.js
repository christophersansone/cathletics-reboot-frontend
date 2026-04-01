import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class OrgsIndexRoute extends Route {
  @service session;
  @service router;

  async model() {
    let memberships = await this.session.currentUser?.organizationMemberships;
    let orgs = [];
    if (memberships) {
      for (let m of memberships.slice()) {
        let org = await m.organization;
        orgs.push({ org, role: m.role });
      }
    }
    return orgs;
  }
}
