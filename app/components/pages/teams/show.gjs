import Component from '@glimmer/component';
import { tracked, cached, action, service, on, fn, array, LinkTo, eq, Await, Errors, LoadingIndicator, args, DeferredPromise } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard, UiBadge, UiModal, UiSelect, UiTypeableSelect } from 'frontend/components/ui';
import InfiniteScroll from '../../infinite-scroll';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

const ROLE_OPTIONS = ['player', 'coach', 'assistant_coach', 'manager'];

const ROLE_VARIANTS = {
  player: 'default',
  coach: 'primary',
  assistant_coach: 'secondary',
  manager: 'secondary',
};

function roleLabel(role) {
  if (role === 'assistant_coach') return 'Asst. Coach';
  return role ? role.charAt(0).toUpperCase() + role.slice(1) : '';
}

function roleVariant(role) {
  return ROLE_VARIANTS[role] || 'default';
}

class AddMemberModal {
  promise = null;
  atomic = null;
  team = null;
  @tracked selectedUser = null;
  @tracked role = 'player';

  constructor({ team, atomic }) {
    this.atomic = atomic;
    this.team = team;
    this.promise = new DeferredPromise();
  }

  saveTask = task({ drop: true }, async () => {
    const model = await this.atomic.createModel('team-membership', {
      user: this.selectedUser,
      team: this.team,
      role: this.role,
    });
    this.promise.resolve({ result: 'saved', model });
  });

  get isSaving() { return this.saveTask.isRunning; }
  get canSave() { return !!this.selectedUser; }

  @action save() { this.saveTask.perform(); }
  @action cancel() { this.promise.resolve({ result: 'canceled' }); }
  @action selectUser(user) { this.selectedUser = user; }
  @action updateRole(event) { this.role = event.target.value; }
}


@args({
  team: { required: true },
  league: { required: true },
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class TeamShowPage extends Component {
  @service atomic;
  @service store;
  @service pagination;
  @service router;
  @service alerts;
  @service('modal') modalService;

  @tracked modal = null;

  @cached
  get rosterPaginator() {
    return this.pagination.query('team-membership', { team_id: this.args.team.id });
  }

  // --- Team Actions ---

  deleteTeam = task(async () => {
    const confirmed = await this.modalService.confirm(`Delete team "${this.args.team.name}"?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(this.args.team);
    this.alerts.success('Team deleted.');
    this.router.transitionTo('orgs.org.leagues.league', this.args.org.slug, this.args.league.id);
  });

  // --- Roster Actions ---

  addMember = task({ drop: true }, async () => {
    try {
      this.modal = new AddMemberModal({ team: this.args.team, atomic: this.atomic });
      const result = await this.modal.promise;
      if (result.model) {
        this.alerts.success('Member added.');
        await this.rosterPaginator.reload();
      }
    } finally {
      this.modal = null;
    }
  });

  updateRole = task(async (membership, event) => {
    const newRole = event.target.value;
    if (newRole === membership.role) return;
    await this.atomic.patchModel(membership, { role: newRole });
    this.alerts.success('Role updated.');
  });

  removeMember = task(async (membership) => {
    const user = await membership.user;
    const name = user?.fullName || 'this member';
    const confirmed = await this.modalService.confirm(`Remove ${name} from the team?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(membership);
    this.alerts.success('Member removed.');
    await this.rosterPaginator.reload();
  });

  @action
  async searchUsers(query) {
    const results = await this.store.query('user', { q: query });
    return results.slice();
  }

  @action
  preventAndSave(event) {
    event.preventDefault();
    this.modal.save();
  }

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>{{@team.name}}</:title>
      <:actions>
        <LinkTo @route="orgs.org.teams.team.edit" @models={{array @org.slug @team.id}}>
          <UiButton @variant="ghost" @size="sm">Edit</UiButton>
        </LinkTo>
        <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" this.deleteTeam.perform}}>
          Delete
        </UiButton>
      </:actions>
      <:meta as |Meta|>
        <Meta @label="League">
          <LinkTo @route="orgs.org.leagues.league" @models={{array @org.slug @league.id}} class="text-link">
            {{@league.name}}
          </LinkTo>
        </Meta>
        <Meta @label="Season" @value={{@season.name}} />
        <Meta @label="Activity" @value={{@activityType.name}} />
      </:meta>
    </DetailHeader>

    <div class="section-header">
      <h2 class="section-header__title">Roster</h2>
      <UiButton @size="sm" {{on "click" this.addMember.perform}}>Add Member</UiButton>
    </div>

    <Await @promise={{this.rosterPaginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Role</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{this.rosterPaginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |membership|>
                <tr>
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
                  <td colspan="3" class="infinite-scroll-page-sentinel"></td>
                </tr>
              </:sentinel>

              <:loading as |loadingModifier|>
                <tr {{loadingModifier}}>
                  <td colspan="3"><LoadingIndicator /></td>
                </tr>
              </:loading>

              <:empty>
                <tr>
                  <td colspan="3">
                    <div class="empty-state">
                      <p class="empty-state__message">No members yet</p>
                      <p class="empty-state__hint">Add players, coaches, and staff to this team's roster.</p>
                      <UiButton class="mt-4" {{on "click" this.addMember.perform}}>Add Member</UiButton>
                    </div>
                  </td>
                </tr>
              </:empty>
            </InfiniteScroll>
          </tbody>
        </table>
      </UiCard>
    </Await>

    {{! ===== Add Member Modal ===== }}

    {{#if this.modal}}
      <UiModal @title="Add Team Member" @onClose={{this.modal.cancel}}>
        <Errors @error={{this.modal.saveTask.last.error}} />
        <form class="flex flex-col gap-4" {{on "submit" this.preventAndSave}}>
          <div class="form-group">
            <label class="form-label">Member</label>
            <UiTypeableSelect
              @options={{array}}
              @selected={{this.modal.selectedUser}}
              @path="fullName"
              @onChange={{this.modal.selectUser}}
              @onSearch={{this.searchUsers}}
              @searchDelay={{300}}
              @placeholder="Search by name..."
            />
          </div>

          <UiSelect
            @label="Role"
            @id="membership-role"
            {{on "change" this.modal.updateRole}}
          >
            {{#each ROLE_OPTIONS as |role|}}
              <option value={{role}} selected={{if (eq this.modal.role role) true}}>
                {{roleLabel role}}
              </option>
            {{/each}}
          </UiSelect>

          <div class="flex gap-3 justify-end">
            <UiButton @variant="secondary" {{on "click" this.modal.cancel}}>Cancel</UiButton>
            <UiButton
              @type="submit"
              @loading={{this.modal.isSaving}}
              disabled={{if this.modal.canSave this.modal.isSaving true}}
            >
              Add
            </UiButton>
          </div>
        </form>
      </UiModal>
    {{/if}}
  </template>
}
