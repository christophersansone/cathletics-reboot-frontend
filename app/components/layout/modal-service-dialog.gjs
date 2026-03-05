import Component from '@glimmer/component';
import { service, on, fn, action, args } from 'frontend/utils/stdlib';
import { UiModal, UiButton } from 'frontend/components/ui';

@args({
  modalDialog: { required: true },
})
export class AlertModalComponent extends Component {
  <template>
    <UiModal @title={{@modalDialog.title}} @onClose={{@modalDialog.resolve}}>
      <:default>
        {{@modalDialog.text}}
      </:default>
      <:footer>
        <UiButton @variant="primary" {{on 'click' @modalDialog.resolve}}>
          {{@modalDialog.okTitle}}
        </UiButton>
      </:footer>
    </UiModal>
  </template>
}

@args({
  modalDialog: { required: true },
})
export class ConfirmModalComponent extends Component {
  <template>
    <UiModal @title={{@modalDialog.title}} @onClose={{fn @modalDialog.resolve false}}>
      <:default>
        {{@modalDialog.text}}
      </:default>
      <:footer>
        <UiButton @variant="ghost" {{on 'click' (fn @modalDialog.resolve false)}}>
          {{@modalDialog.noTitle}}
        </UiButton>
        <UiButton @variant="primary" {{on 'click' (fn @modalDialog.resolve true)}}>
          {{@modalDialog.yesTitle}}
        </UiButton>
      </:footer>
    </UiModal>
  </template>
}

export default class ModalServiceDialogComponent extends Component {
  @service modal;

  get modalDialog() {
    return this.modal.current?.modalDialog;
  }

  get componentClass() {
    return this.modal.current?.componentClass;
  }

  <template>
    {{#if this.modalDialog}}
      {{#let this.componentClass as |ComponentClass|}}
        <ComponentClass @modalDialog={{this.modalDialog}} />
      {{/let}}
    {{/if}}
  </template>
}
