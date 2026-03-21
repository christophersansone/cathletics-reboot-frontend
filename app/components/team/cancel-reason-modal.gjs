import Component from '@glimmer/component';
import { args, on, tracked, action } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiInput } from 'frontend/components/ui';
import { ModalDialog } from 'frontend/services/modal';

export class CancelReasonModal extends ModalDialog {
  @tracked reason = '';

  @action
  submit() {
    this.promise.resolve({ reason: this.reason?.trim() ?? '' });
  }

  @action
  cancel() {
    this.promise.resolve(null);
  }

  @action
  updateReason(e) {
    this.reason = e.target?.value ?? '';
  }
}

@args({
  modalDialog: { type: CancelReasonModal, required: true },
})
export default class CancelReasonModalComponent extends Component {
  <template>
    <UiModal @title="Cancel this event" @onClose={{@modalDialog.cancel}}>
      <:default>
        <p class="mb-3">Optionally add a reason (e.g. &quot;Canceled due to rain&quot;). It will be shown on the schedule.</p>
        <UiInput
          @label="Reason (optional)"
          @value={{@modalDialog.reason}}
          @placeholder="e.g. Canceled due to rain"
          {{on "input" @modalDialog.updateReason}}
        />
      </:default>
      <:footer>
        <UiButton @variant="ghost" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
        <UiButton @variant="primary" {{on "click" @modalDialog.submit}}>Confirm cancellation</UiButton>
      </:footer>
    </UiModal>
  </template>
}
