import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { array } from '@ember/helper';
import { task } from 'ember-concurrency';
import { LinkTo } from '@ember/routing';
import UiCard from '../../ui/card';
import SeasonForm from '../../season/form';
import Errors from '../../errors';
import args from 'frontend/decorators/args';
import Breadcrumbs from '../../layout/breadcrumbs';
import DetailHeader from '../../layout/detail-header';

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
