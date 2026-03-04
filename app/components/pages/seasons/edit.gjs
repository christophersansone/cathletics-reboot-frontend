import Component from '@glimmer/component';
import { cached, service, Errors, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiCard } from 'frontend/components/ui';
import SeasonForm from '../../season/form';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

@args({
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class SeasonEditPage extends Component {
  @service atomic;
  @service router;
  @service alerts;

  @cached
  get trackedModel() {
    return this.atomic.trackedModel(this.args.season);
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.args.season, this.trackedModel);
    this.alerts.success('Season updated.');
    this.router.transitionTo('orgs.org.seasons.season', this.args.org.slug, this.args.season.id);
  });

  cancel = () => {
    this.router.transitionTo('orgs.org.seasons.season', this.args.org.slug, this.args.season.id);
  };

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>Edit Season</:title>
    </DetailHeader>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} class="errors" />
        <SeasonForm
          @season={{this.trackedModel}}
          @timeZone={{@season.effectiveTimeZone}}
          @onSave={{this.saveTask.perform}}
          @onCancel={{this.cancel}}
          @isSaving={{this.saveTask.isRunning}}
          @isNew={{false}}
        />
      </UiCard>
    </div>
  </template>
}
