import Component from '@glimmer/component';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { action } from '@ember/object';
import UiModal from 'frontend/components/ui/modal';
import UiButton from 'frontend/components/ui/button';

export default class ModalServiceDialogComponent extends Component {
  @service modal;

  get dialog() {
    return this.modal.current;
  }

  get isAlert() {
    return this.dialog?.type === 'alert';
  }

  get isConfirm() {
    return this.dialog?.type === 'confirm';
  }

  @action
  resolve(value) {
    this.dialog.resolve(value);
  }

  <template>
    {{#if this.isAlert}}
      <UiModal @title={{this.dialog.title}} @onClose={{this.resolve}}>
        <:default>
          {{this.dialog.text}}
        </:default>
        <:footer>
          <UiButton @variant="primary" {{on 'click' this.resolve}}>
            {{this.dialog.okTitle}}
          </UiButton>
        </:footer>
      </UiModal>
    {{/if}}

    {{#if this.isConfirm}}
      <UiModal @title={{this.dialog.title}} @onClose={{fn this.resolve false}}>
        <:default>
          {{this.dialog.text}}
        </:default>
        <:footer>
          <UiButton @variant="ghost" {{on 'click' (fn this.resolve false)}}>
            {{this.dialog.noTitle}}
          </UiButton>
          <UiButton @variant="primary" {{on 'click' (fn this.resolve true)}}>
            {{this.dialog.yesTitle}}
          </UiButton>
        </:footer>
      </UiModal>
    {{/if}}
  </template>
}
