import Component from '@glimmer/component';
import { Errors, on, action, tracked, eq, args, array } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiSelect, UiTypeableSelect } from 'frontend/components/ui';
import autoFocus from 'frontend/modifiers/auto-focus';
import { ModalDialog } from 'frontend/services/modal';
import { task } from 'ember-concurrency';
import preventDefault from 'frontend/helpers/prevent-default';

const ROLE_OPTIONS = ['player', 'coach', 'assistant_coach', 'manager'];

function roleLabel(role) {
  if (role === 'assistant_coach') return 'Asst. Coach';
  return role ? role.charAt(0).toUpperCase() + role.slice(1) : '';
}

export class AddMemberModal extends ModalDialog {
  atomic = null;
  team = null;
  onSearch = null;
  @tracked selectedUser = null;
  @tracked role = 'player';

  constructor({ team, atomic, onSearch }) {
    super();
    this.atomic = atomic;
    this.team = team;
    this.onSearch = onSearch;
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
  modalDialog: { type: ModalDialog, required: true },
})
export default class TeamMembershipModalComponent extends Component {
  <template>
    <UiModal @title="Add Team Member" @onClose={{@modalDialog.cancel}}>
      <Errors @error={{@modalDialog.saveTask.last.error}} />
      <form class="flex flex-col gap-4" {{on "submit" (preventDefault @modalDialog.save)}}>
        <div class="form-group">
          <label class="form-label">Member</label>
          <UiTypeableSelect
            @options={{array}}
            @selected={{@modalDialog.selectedUser}}
            @path="fullName"
            @onChange={{@modalDialog.selectUser}}
            @onSearch={{@modalDialog.onSearch}}
            @searchDelay={{300}}
            @placeholder="Search by name..."
            {{autoFocus}}
          />
        </div>

        <UiSelect
          @label="Role"
          @id="membership-role"
          {{on "change" @modalDialog.updateRole}}
        >
          {{#each ROLE_OPTIONS as |role|}}
            <option value={{role}} selected={{if (eq @modalDialog.role role) true}}>
              {{roleLabel role}}
            </option>
          {{/each}}
        </UiSelect>

        <div class="flex gap-3 justify-end">
          <UiButton @variant="secondary" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
          <UiButton
            @type="submit"
            @loading={{@modalDialog.isSaving}}
            disabled={{if @modalDialog.canSave @modalDialog.isSaving true}}
          >
            Add
          </UiButton>
        </div>
      </form>
    </UiModal>
  </template>
}
