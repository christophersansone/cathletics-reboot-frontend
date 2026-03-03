import Route from '@ember/routing/route';

export default class SeasonEditRoute extends Route {
  async model() {
    const season = this.modelFor('orgs.org.seasons.season');
    const activityType = await season.activityType;
    return {
      season,
      activityType,
      org: this.modelFor('orgs.org'),
    };
  }
}
