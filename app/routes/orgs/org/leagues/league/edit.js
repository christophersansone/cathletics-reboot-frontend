import Route from '@ember/routing/route';

export default class LeagueEditRoute extends Route {
  async model() {
    const league = this.modelFor('orgs.org.leagues.league');
    const season = await league.season;
    const activityType = await season.activityType;
    return {
      league,
      season,
      activityType,
      org: this.modelFor('orgs.org'),
    };
  }
}
