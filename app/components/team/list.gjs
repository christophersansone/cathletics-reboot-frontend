import Component from '@glimmer/component';
import { on, fn, array, LinkTo, Await, LoadingIndicator, args, service } from 'frontend/utils/stdlib';
import { UiCard, UiButton } from 'frontend/components/ui';
import InfiniteScroll from 'frontend/components/infinite-scroll';
import Organization from 'frontend/models/organization';
import Paginator from 'frontend/utils/paginator';
import { task } from 'ember-concurrency';
import TeamModalComponent, { EditTeamModal } from './modal';

@args({
  org: { type: Organization, required: true },
  paginator: { type: Paginator, required: true },
  onCreate: { type: 'function' },
})
export default class TeamListComponent extends Component {
  @service atomic;
  @service alerts;
  @service modal;

  editTeam = task({ drop: true }, async (team) => {
    const modalDialog = new EditTeamModal({ model: team, atomic: this.atomic });
    const result = await this.modal.execute(modalDialog, TeamModalComponent);
    if (result.result === 'saved') {
      this.alerts.success('Team updated.');
    }
  });

  deleteTeam = task(async (team) => {
    const confirmed = await this.modal.confirm(`Delete team "${team.name}"?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(team);
    this.alerts.success('Team deleted.');
    await this.args.paginator.reload();
  });

  <template>
    <Await @promise={{@paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{@paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |team|>
                <tr>
                  <td class="font-medium">
                    <LinkTo @route="orgs.org.teams.team" @models={{array @org.slug team.id}} class="text-link">
                      {{team.name}}
                    </LinkTo>
                  </td>
                  <td class="data-table__actions">
                    <UiButton @variant="ghost" @size="sm" {{on "click" (fn this.editTeam.perform team)}}>
                      Edit
                    </UiButton>
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.deleteTeam.perform team)}}>
                      Delete
                    </UiButton>
                  </td>
                </tr>
              </:item>

              <:sentinel as |sentinelModifier|>
                <tr {{sentinelModifier}}>
                  <td colspan="2" class="infinite-scroll-page-sentinel"></td>
                </tr>
              </:sentinel>

              <:loading as |loadingModifier|>
                <tr {{loadingModifier}}>
                  <td colspan="2"><LoadingIndicator /></td>
                </tr>
              </:loading>

              <:empty>
                <tr>
                  <td colspan="2">
                    <div class="empty-state">
                      <p class="empty-state__message">No teams yet</p>
                      <p class="empty-state__hint">Create teams to organize players into groups within this league.</p>
                      {{#if @onCreate}}
                        <UiButton class="mt-4" {{on "click" @onCreate}}>Create Team</UiButton>
                      {{/if}}
                    </div>
                  </td>
                </tr>
              </:empty>
            </InfiniteScroll>
          </tbody>
        </table>
      </UiCard>
    </Await>
  </template>
}
