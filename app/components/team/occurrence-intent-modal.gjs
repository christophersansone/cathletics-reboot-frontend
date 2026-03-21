import Component from '@glimmer/component';
import { args, on, fn, action } from 'frontend/utils/stdlib';
import { UiModal, UiButton } from 'frontend/components/ui';
import { ModalDialog } from 'frontend/services/modal';

export class OccurrenceIntentModal extends ModalDialog {
  /** @type {'edit'|'cancel'|'remove'} */
  action = 'edit';
  /** @type {{ startAt: string, title: string, isRecurring?: boolean }} */
  occurrence = null;

  constructor({ action = 'edit', occurrence }) {
    super();
    this.action = action;
    this.occurrence = occurrence;
  }

  get title() {
    const verb = this.action === 'edit' ? 'Edit' : this.action === 'cancel' ? 'Cancel' : 'Remove';
    return `${verb} this event`;
  }

  get bodyText() {
    return 'Apply to this occurrence only or to this and all future occurrences?';
  }

  @action
  choose(scope) {
    this.promise.resolve({ scope });
  }

  @action
  cancel() {
    this.promise.resolve(null);
  }
}

@args({
  modalDialog: { type: OccurrenceIntentModal, required: true },
})
export default class OccurrenceIntentModalComponent extends Component {
  <template>
    <UiModal @title={{@modalDialog.title}} @onClose={{@modalDialog.cancel}}>
      <:default>
        <p>{{@modalDialog.bodyText}}</p>
      </:default>
      <:footer>
        <UiButton @variant="ghost" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
        <UiButton @variant="secondary" {{on "click" (fn @modalDialog.choose "this_one")}}>
          This occurrence only
        </UiButton>
        <UiButton @variant="primary" {{on "click" (fn @modalDialog.choose "all_future")}}>
          All future events
        </UiButton>
      </:footer>
    </UiModal>
  </template>
}
