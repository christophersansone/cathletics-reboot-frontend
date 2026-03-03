import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { array } from '@ember/helper';
import { task } from 'ember-concurrency';
import { LinkTo } from '@ember/routing';
import { or } from 'ember-truth-helpers';
import UiCard from '../../ui/card';
import LeagueForm from '../../league/form';
import Errors from '../../errors';
import args from 'frontend/decorators/args';
import Breadcrumbs from 'frontend/components/layout/breadcrumbs';
import DetailHeader from '../../layout/detail-header';

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
