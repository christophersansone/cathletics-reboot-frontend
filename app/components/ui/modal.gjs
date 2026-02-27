import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';

export default class UiModal extends Component {
  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.args.onClose();
    }
  }

  <template>
    <div class="modal-backdrop" role="presentation" {{on "click" this.handleBackdropClick}} {{on "keydown" this.handleKeydown}}>
      <div class="modal" role="dialog" aria-modal="true" ...attributes>
        <div class="modal__header">
          <h2 class="modal__title">{{@title}}</h2>
          <button type="button" class="modal__close" {{on "click" @onClose}} aria-label="Close">&times;</button>
        </div>
        <div class="modal__body">
          {{yield}}
        </div>
        {{#if (has-block "footer")}}
          <div class="modal__footer">
            {{yield to="footer"}}
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}
