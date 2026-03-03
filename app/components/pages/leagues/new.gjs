import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { array } from '@ember/helper';
import { task } from 'ember-concurrency';
import { LinkTo } from '@ember/routing';
import UiCard from '../../ui/card';
import LeagueForm from '../../league/form';
import Errors from '../../errors';
import args from 'frontend/decorators/args';
import Breadcrumbs from '../../layout/breadcrumbs';

@args({
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class LeaguesNewPage extends Component {
  @service atomic;
  @service router;
  @service alerts;

  @cached
  get trackedModel() {
    return this.atomic.newTrackedModel('league', { season: this.args.season });
  }

  saveTask = task({ drop: true }, async () => {
    const league = await this.atomic.createModel('league', this.trackedModel);
    this.alerts.success('League created.');
    this.router.transitionTo('orgs.org.leagues.league', this.args.org.slug, league.id);
  });

  cancel = () => {
    this.router.transitionTo('orgs.org.seasons.season', this.args.org.slug, this.args.season.id);
  };

  <template>
    <Breadcrumbs />

    <div class="detail-header">
      <h1 class="detail-header__title">New League</h1>
      <p class="detail-header__description">Create a league for {{@season.name}}</p>
    </div>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} class="errors" />
        <LeagueForm
          @league={{this.trackedModel}}
          @onSave={{this.saveTask.perform}}
          @onCancel={{this.cancel}}
          @isSaving={{this.saveTask.isRunning}}
          @isNew={{true}}
        />
      </UiCard>
    </div>
  </template>
}
