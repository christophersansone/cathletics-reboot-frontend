import Route from '@ember/routing/route';

export default class TeamIndexRoute extends Route {
  async model() {
    const team = this.modelFor('orgs.org.teams.team');
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    return {
      team,
      league,
      season,
      activityType,
      org: this.modelFor('orgs.org'),
    };
  }
}
