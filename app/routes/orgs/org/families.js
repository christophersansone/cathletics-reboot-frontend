import Route from '@ember/routing/route';

export default class FamiliesRoute extends Route {
  model() {
    return { org: this.modelFor('orgs.org') };
  }
}
