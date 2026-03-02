import Modifier from 'ember-modifier';
import { registerDestructor } from '@ember/destroyable';
import { isMobileDevice } from 'frontend/utils/platform';

export default class AutoFocusModifier extends Modifier {
  element = null;
  target = null;
  delayTimer = null;

  modify(element, [target], { delay }) {
    if (isMobileDevice()) {
      return;
    }

    this.element = element;
    this.target = target;
    if (delay) {
      const delayFn = () => this.performFocus();
      this.delayTimer = window.setTimeout(delayFn, delay);
    } else {
      this.performFocus();
    }
  }

  performFocus() {
    this.delayTimer = null;
    const element = this.element;
    const target = this.target;
    const focusElement = target ? element.querySelector(target) : element;
    if (focusElement) {
      focusElement.focus();
    }
    this.cleanup();
  }

  cleanup() {
    this.element = null;
    this.target = null;
    if (this.delayTimer) {
      window.clearTimeout(this.delayTimer);
      this.delayTimer = null;
    }
  }

  constructor(owner, args) {
    super(owner, args);
    registerDestructor(this, () => this.cleanup());
  }

  // backwards compatibility with ember-modifiers@3.0.0
  didReceiveArguments() {
    this.modify(this.element, this.args.positional, this.args.named);
  }
}
