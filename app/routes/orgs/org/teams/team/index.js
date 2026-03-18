import Route from '@ember/routing/route';

export default class TeamIndexRoute extends Route {
  async model() {
    const parent = this.modelFor('orgs.org.teams.team');
    const team = parent.team ?? parent;
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    return {
      team,
      league,
      season,
      activityType,
      org: parent.org ?? this.modelFor('orgs.org'),
    };
  }
}
