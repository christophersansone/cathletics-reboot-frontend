import Component from '@glimmer/component';
import { action, on, args } from 'frontend/utils/stdlib';
import { task, timeout } from 'ember-concurrency';

@args({
  title: { type: 'string', required: true },
  onClose: { type: 'function', required: true },
})
export default class UiModal extends Component {
  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.close();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.close();
    }
  }

  @action
  close() {
    this.closeTask.perform();
  }

  closeTask = task({ drop: true }, async () => {
    await timeout(300);
    this.args.onClose();
  })

  get isClosing() {
    return this.closeTask.isRunning;
  }

  <template>
    <div class="modal-backdrop {{if this.isClosing 'closing'}}" role="presentation" {{on "click" this.handleBackdropClick}} {{on "keydown" this.handleKeydown}}>
      <div class="modal" role="dialog" aria-modal="true" ...attributes>
        <div class="header">
          <h2 class="title">{{@title}}</h2>
          <button type="button" class="close" {{on "click" this.close}} aria-label="Close">&times;</button>
        </div>
        <div class="body">
          {{yield}}
        </div>
        {{#if (has-block "footer")}}
          <div class="footer">
            {{yield to="footer"}}
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}
