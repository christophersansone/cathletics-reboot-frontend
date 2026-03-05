import Route from '@ember/routing/route';

export default class MembersRoute extends Route {
  model() {
    return { org: this.modelFor('orgs.org') };
  }
}
