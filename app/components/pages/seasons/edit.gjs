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
