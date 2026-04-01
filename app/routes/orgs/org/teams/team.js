import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class TeamRoute extends Route {
  @service store;
  @service cache;

  async model(params) {
    const team = await this.store.findRecord('team', params.team_id);
    const org = this.modelFor('orgs.org');
    await this.loadTeamAssociatedMembers(params.team_id);
    return { team, org };
  }

  async loadTeamAssociatedMembers(teamId) {
    const members = await this.store.adapterFor('team').associatedMembersFor(teamId);
    this.cache.set(`team-${teamId}-associated-members`, members);
    return members;
  }

  async breadcrumbParents(model) {
    const team = model.team;
    const org = model.org;
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    return [
      { route: 'orgs.org.activity-types', model: [org] },
      { route: 'orgs.org.activity-types.activity-type', model: [org, activityType] },
      { route: 'orgs.org.seasons.season', model: [org, season] },
      { route: 'orgs.org.leagues.league', model: [org, league] },
    ];
  }

  breadcrumb(model) {
    return { title: model.team.name };
  }
}
