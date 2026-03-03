import Route from '@ember/routing/route';

export default class NewLeagueRoute extends Route {
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
