import Component from '@glimmer/component';
import { cached, service, Errors, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiCard } from 'frontend/components/ui';
import SeasonForm from '../../season/form';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

@args({
  activityType: { required: true },
  org: { required: true },
})
export default class SeasonsNewPage extends Component {
  @service atomic;
  @service router;
  @service alerts;

  @cached
  get trackedModel() {
    return this.atomic.newTrackedModel('season', { activityType: this.args.activityType });
  }

  saveTask = task({ drop: true }, async () => {
    const season = await this.atomic.createModel('season', this.trackedModel);
    this.alerts.success('Season created.');
    this.router.transitionTo('orgs.org.seasons.season', this.args.org.slug, season.id);
  });

  cancel = () => {
    this.router.transitionTo(
      'orgs.org.activity-types.activity-type',
      this.args.org.slug,
      this.args.activityType.id,
    );
  };

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>New Season</:title>
      <:description>Create a season for {{@activityType.name}}</:description>
    </DetailHeader>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} class="errors" />
        <SeasonForm
          @season={{this.trackedModel}}
          @timeZone={{@org.timeZone}}
          @onSave={{this.saveTask.perform}}
          @onCancel={{this.cancel}}
          @isSaving={{this.saveTask.isRunning}}
          @isNew={{true}}
        />
      </UiCard>
    </div>
  </template>
}
