import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { args } from 'frontend/decorators/args';
import viewTransition from 'frontend/modifiers/view-transition';

@args({
  name: { type: 'string', required: true },
  value: { required: true },
})
export default class UiAnimatedValueComponent extends Component {
  // Initialize the local value to the initial value
  // eslint-disable-next-line ember/no-tracked-properties-from-args
  @tracked localValue = this.args.value;

  get didChange() {
    return this.localValue !== this.args.value;
  }

  @action
  doChange() {
    this.localValue = this.args.value;
  }

  <template>
    <div ...attributes {{viewTransition transitionName=@name didChange=this.didChange onExecute=this.doChange}}>
      {{yield this.localValue}}
    </div>
  </template>
}
