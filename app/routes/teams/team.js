import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class TeamsTeamRoute extends Route {
  @service store;
  @service cache;

  async model(params) {
    const team = await this.store.findRecord('team', params.team_id);
    await this.loadTeamAssociatedMembers(params.team_id);
    return team;
  }

  async loadTeamAssociatedMembers(teamId) {
    const members = await this.store.adapterFor('team').associatedMembersFor(teamId);
    this.cache.set(`team-${teamId}-associated-members`, members);
    return members;
  }
}
