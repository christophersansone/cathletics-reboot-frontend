import Component from '@glimmer/component';
import { cached, service, Errors, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiCard } from 'frontend/components/ui';
import LeagueForm from '../../league/form';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

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

    <DetailHeader>
      <:title>New League</:title>
      <:description>Create a league for {{@season.name}}</:description>
    </DetailHeader>

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
