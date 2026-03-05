import Component from '@glimmer/component';
import { Errors, on, action, tracked, args, array } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiTypeableSelect } from 'frontend/components/ui';
import autoFocus from 'frontend/modifiers/auto-focus';
import { ModalDialog } from 'frontend/services/modal';
import { task } from 'ember-concurrency';
import preventDefault from 'frontend/helpers/prevent-default';

export class CreateRegistrationModal extends ModalDialog {
  atomic = null;
  league = null;
  onSearch = null;

  @tracked selectedUser = null;

  constructor({ league, atomic, onSearch }) {
    super();
    this.atomic = atomic;
    this.league = league;
    this.onSearch = onSearch;
  }

  saveTask = task({ drop: true }, async () => {
    const model = await this.atomic.createModel('registration', {
      user: this.selectedUser,
      league: this.league,
      status: 'pending',
    });
    this.promise.resolve({ result: 'saved', model });
  });

  get isSaving() { return this.saveTask.isRunning; }
  get canSave() { return !!this.selectedUser; }

  @action save() { this.saveTask.perform(); }
  @action cancel() { this.promise.resolve({ result: 'canceled' }); }
  @action selectUser(user) { this.selectedUser = user; }
}

@args({
  modalDialog: { type: ModalDialog, required: true },
})
export default class RegistrationModalComponent extends Component {
  <template>
    <UiModal @title="Register Participant" @onClose={{@modalDialog.cancel}}>
      <Errors @error={{@modalDialog.saveTask.last.error}} />
      <form class="flex flex-col gap-4" {{on "submit" (preventDefault @modalDialog.save)}}>
        <div class="form-group">
          <label class="form-label">Participant</label>
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
        <div class="flex gap-3 justify-end">
          <UiButton @variant="secondary" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
          <UiButton
            @type="submit"
            @loading={{@modalDialog.isSaving}}
            disabled={{if @modalDialog.canSave @modalDialog.isSaving true}}
          >
            Register
          </UiButton>
        </div>
      </form>
    </UiModal>
  </template>
}
