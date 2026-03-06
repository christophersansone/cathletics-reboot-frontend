import Component from '@glimmer/component';
import { args } from 'frontend/utils/stdlib';
import { task, timeout } from 'ember-concurrency';

// Simple component that renders the block if @value is true,
// and when @value becomes false, will delay the removal of the content
// so that an out animation can complete
@args({
  value: { required: true },
  delay: { type: 'number' },
})
export default class UiAnimationRenderIfComponent extends Component {

  get delay() {
    return this.args.delay ?? 1000;
  }

  get shouldRender() {
    return this.value || this.isClosing;
  }

  get value() {
    const value = this.args.value;
    if (this._lastValue !== value) {
      const shouldClose = this._lastValue && !value;
      if (shouldClose) {
        this.close.perform();
      } else {
        this.close.cancelAll();
      }
      // eslint-disable-next-line ember/no-side-effects
      this._lastValue = value;
    }
    return value;
  }

  close = task(async () => {
    return await timeout(this.delay);
  });

  get isClosing() {
    return this.close.isRunning;
  }

  <template>
    {{#if this.shouldRender}}
      {{yield this.value}}
    {{/if}}
  </template>
}
