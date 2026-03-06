import Route from '@ember/routing/route';

export default class TeamsTeamRosterRoute extends Route {
  model() {
    return this.modelFor('teams.team');
  }
}
