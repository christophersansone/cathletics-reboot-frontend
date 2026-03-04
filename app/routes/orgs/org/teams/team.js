import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class TeamRoute extends Route {
  @service store;

  model(params) {
    return this.store.findRecord('team', params.team_id);
  }

  async breadcrumbParents(model) {
    const org = this.modelFor('orgs.org');
    const league = await model.league;
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
    return { title: model.name };
  }
}
