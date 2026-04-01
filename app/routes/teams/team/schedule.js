import Route from '@ember/routing/route';

export default class TeamsTeamScheduleRoute extends Route {
  model() {
    return this.modelFor('teams.team');
  }
}
