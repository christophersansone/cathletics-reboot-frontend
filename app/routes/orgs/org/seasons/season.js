import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class SeasonRoute extends Route {
  @service store;

  model(params) {
    return this.store.findRecord('season', params.season_id);
  }

  async breadcrumbParents(model) {
    const org = this.modelFor('orgs.org');
    const activityType = await model.activityType;
    return [
      { route: 'orgs.org.activity-types', model: [ org ] },
      { route: 'orgs.org.activity-types.activity-type', model: [ org, activityType ] },
    ]
  }

  breadcrumb(model) {
    return { title: model.name };
  }
}
