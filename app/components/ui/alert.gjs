import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import args from 'frontend/decorators/args';
import { task, timeout } from 'ember-concurrency';

const VARIANTS = {
  danger: 'alert--danger',
  success: 'alert--success',
  warning: 'alert--warning',
  primary: 'alert--primary',
  info: 'alert--info',
};

@args({
  variant: { type: 'string' },
  dismissible: { type: 'boolean' },
  timeout: { type: 'number' },
  onDismiss: { type: 'function' },
})
export default class UiAlert extends Component {
  constructor() {
    super(...arguments);
    if (this.args.timeout) {
      this.scheduleDismiss.perform(this.args.timeout);
    }
  }

  scheduleDismiss = task({ drop: true }, async () => {
    await timeout(this.args.timeout);
    this.args.onDismiss?.();
  })

  get classes() {
    return `alert ${VARIANTS[this.args.variant ?? 'info']}`;
  }

  @action
  dismiss() {
    this.scheduleDismiss.cancelAll();
    this.args.onDismiss?.();
  }

  <template>
    <div class={{this.classes}} role="alert" ...attributes>
      <div class="alert__body">{{yield}}</div>
      {{#if @dismissible}}
        <button type="button" class="alert__close" aria-label="Dismiss" {{on "click" this.dismiss}}>&times;</button>
      {{/if}}
    </div>
  </template>
}
