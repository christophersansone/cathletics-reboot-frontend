import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import args from 'frontend/decorators/args';
import { task, timeout } from 'ember-concurrency';
import { scopedClass } from 'ember-scoped-css';

const VARIANTS = {
  danger: scopedClass('alert--danger'),
  success: scopedClass('alert--success'),
  warning: scopedClass('alert--warning'),
  primary: scopedClass('alert--primary'),
  info: scopedClass('alert--info'),
};

@args({
  variant: { type: 'string' },
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

  get variantClass() {
    return VARIANTS[this.args.variant ?? 'info'];
  }

  @action
  dismiss() {
    this.scheduleDismiss.cancelAll();
    this.args.onDismiss?.();
  }

  <template>
    <div class="alert {{this.variantClass}}" role="alert" ...attributes>
      <div class="alert__body">{{yield}}</div>
      {{#if @onDismiss}}
        <button type="button" class="alert__close" aria-label="Dismiss" {{on "click" this.dismiss}}>&times;</button>
      {{/if}}
    </div>
  </template>
}
