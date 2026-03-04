import Component from '@glimmer/component';
import { cached, service, Errors, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiCard } from 'frontend/components/ui';
import LeagueForm from '../../league/form';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

@args({
  league: { required: true },
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class LeagueEditPage extends Component {
  @service atomic;
  @service router;
  @service alerts;

  @cached
  get trackedModel() {
    return this.atomic.trackedModel(this.args.league);
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.args.league, this.trackedModel);
    this.alerts.success('League updated.');
    this.router.transitionTo('orgs.org.leagues.league', this.args.org.slug, this.args.league.id);
  });

  cancel = () => {
    this.router.transitionTo('orgs.org.leagues.league', this.args.org.slug, this.args.league.id);
  };

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>Edit League</:title>
    </DetailHeader>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} class="errors" />
        <LeagueForm
          @league={{this.trackedModel}}
          @onSave={{this.saveTask.perform}}
          @onCancel={{this.cancel}}
          @isSaving={{this.saveTask.isRunning}}
          @isNew={{false}}
        />
      </UiCard>
    </div>
  </template>
}
