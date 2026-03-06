import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class TeamsTeamIndexRoute extends Route {
  @service router;

  beforeModel() {
    this.router.transitionTo('teams.team.roster');
  }
}
