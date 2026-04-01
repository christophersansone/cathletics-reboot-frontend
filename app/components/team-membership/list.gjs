import Component from '@glimmer/component';
import { on, fn, Await, LoadingIndicator, args, service, eq } from 'frontend/utils/stdlib';
import { UiCard, UiButton } from 'frontend/components/ui';
import InfiniteScroll from 'frontend/components/infinite-scroll';
import Paginator from 'frontend/utils/paginator';
import { task } from 'ember-concurrency';

const ROLE_OPTIONS = ['player', 'coach', 'assistant_coach', 'manager'];

function roleLabel(role) {
  if (role === 'assistant_coach') return 'Asst. Coach';
  return role ? role.charAt(0).toUpperCase() + role.slice(1) : '';
}

@args({
  paginator: { type: Paginator, required: true },
  onCreate: { type: 'function', allowNull: true },
})
export default class TeamMembershipListComponent extends Component {
  @service atomic;
  @service alerts;
  @service modal;

  updateRole = task(async (membership, event) => {
    const newRole = event.target.value;
    if (newRole === membership.role) return;
    await this.atomic.patchModel(membership, { role: newRole });
    this.alerts.success('Role updated.');
  });

  updateUniformNumber = task(async (membership, event) => {
    const value = event.target.value.trim() || null;
    if (value === membership.uniformNumber) return;
    await this.atomic.patchModel(membership, { uniformNumber: value });
  });

  updatePosition = task(async (membership, event) => {
    const value = event.target.value.trim() || null;
    if (value === membership.position) return;
    await this.atomic.patchModel(membership, { position: value });
  });

  removeMember = task(async (membership) => {
    const user = await membership.user;
    const name = user?.fullName || 'this member';
    const confirmed = await this.modal.confirm(`Remove ${name} from the team?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(membership);
    this.alerts.success('Member removed.');
    await this.args.paginator.reload();
  });

  <template>
    <Await @promise={{@paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Position</th>
              <th>Name</th>
              <th>Role</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{@paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |membership|>
                <tr>
                  <td class="data-table__num-col">
                    <input
                      type="text"
                      inputmode="numeric"
                      aria-label="Uniform number"
                      class="form-input form-input--inline form-input--num"
                      value={{membership.uniformNumber}}
                      placeholder="—"
                      {{on "change" (fn this.updateUniformNumber.perform membership)}}
                    />
                  </td>
                  <td>
                    <input
                      type="text"
                      aria-label="Position"
                      class="form-input form-input--inline"
                      value={{membership.position}}
                      placeholder="—"
                      {{on "change" (fn this.updatePosition.perform membership)}}
                    />
                  </td>
                  <td class="font-medium">
                    <Await @promise={{membership.user}} as |user|>
                      {{user.fullName}}
                    </Await>
                  </td>
                  <td>
                    <select
                      aria-label="Member role"
                      class="form-select form-select--inline"
                      {{on "change" (fn this.updateRole.perform membership)}}
                    >
                      {{#each ROLE_OPTIONS as |role|}}
                        <option value={{role}} selected={{if (eq membership.role role) true}}>
                          {{roleLabel role}}
                        </option>
                      {{/each}}
                    </select>
                  </td>
                  <td class="data-table__actions">
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.removeMember.perform membership)}}>
                      Remove
                    </UiButton>
                  </td>
                </tr>
              </:item>

              <:sentinel as |sentinelModifier|>
                <tr {{sentinelModifier}}>
                  <td colspan="4" class="infinite-scroll-page-sentinel"></td>
                </tr>
              </:sentinel>

              <:loading as |loadingModifier|>
                <tr {{loadingModifier}}>
                  <td colspan="4"><LoadingIndicator /></td>
                </tr>
              </:loading>

              <:empty>
                <tr>
                  <td colspan="4">
                    <div class="empty-state">
                      <p class="empty-state__message">No members yet</p>
                      <p class="empty-state__hint">Add players, coaches, and staff to this team's roster.</p>
                      {{#if @onCreate}}
                        <UiButton class="mt-4" {{on "click" @onCreate}}>Add Member</UiButton>
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
