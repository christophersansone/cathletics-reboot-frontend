import Route from '@ember/routing/route';

export default class NewSeasonRoute extends Route {
  model() {
    return {
      activityType: this.modelFor('orgs.org.activity-types.activity-type'),
      org: this.modelFor('orgs.org'),
    };
  }
}
