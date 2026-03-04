import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { fn, array } from '@ember/helper';
import { task } from 'ember-concurrency';
import UiButton from '../../ui/button';
import UiCard from '../../ui/card';
import UiInput from '../../ui/input';
import Errors from '../../errors';
import args from 'frontend/decorators/args';
import Breadcrumbs from '../../layout/breadcrumbs';
import DetailHeader from '../../layout/detail-header';
import autoFocus from 'frontend/modifiers/auto-focus';

@args({
  team: { required: true },
  league: { required: true },
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class TeamEditPage extends Component {
  @service atomic;
  @service router;
  @service alerts;

  @cached
  get trackedModel() {
    return this.atomic.trackedModel(this.args.team);
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.args.team, this.trackedModel);
    this.alerts.success('Team updated.');
    this.router.transitionTo('orgs.org.teams.team', this.args.org.slug, this.args.team.id);
  });

  cancel = () => {
    this.router.transitionTo('orgs.org.teams.team', this.args.org.slug, this.args.team.id);
  };

  updateName = (event) => {
    this.trackedModel.name = event.target.value;
  };

  handleSubmit = (event) => {
    event.preventDefault();
    this.saveTask.perform();
  };

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>Edit Team</:title>
    </DetailHeader>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} />
        <form class="flex flex-col gap-4" {{on "submit" this.handleSubmit}}>
          <UiInput
            @label="Team Name"
            @value={{this.trackedModel.name}}
            @placeholder="e.g. Team A, Blue Team"
            @id="team-name"
            {{on "input" this.updateName}}
            {{autoFocus}}
          />
          <div class="flex gap-3 justify-end">
            <UiButton @variant="secondary" {{on "click" this.cancel}}>Cancel</UiButton>
            <UiButton @type="submit" @loading={{this.saveTask.isRunning}} disabled={{this.saveTask.isRunning}}>
              Save
            </UiButton>
          </div>
        </form>
      </UiCard>
    </div>
  </template>
}
