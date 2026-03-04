import Component from '@glimmer/component';
import { tracked, action, args } from 'frontend/utils/stdlib';
import viewTransition from 'frontend/modifiers/view-transition';

@args({
  name: { type: 'string', required: true },
  value: { required: true },
})
export default class UiAnimatedIfComponent extends Component {
  // Initialize the local value to the initial value
  @tracked localValue = !!this.args.value;

  get didChange() {
    return !!this.localValue !== !!this.args.value;
  }

  @action
  doChange() {
    this.localValue = !!this.args.value;
  }

  get transitionName() {
    return `vt-if-${this.args.name}`;
  }

  <template>
    <div ...attributes {{viewTransition transitionName=this.transitionName didChange=this.didChange onExecute=this.doChange}}>
      {{#if this.localValue}}
        {{yield}}
      {{/if}}
    </div>
  </template>
}
