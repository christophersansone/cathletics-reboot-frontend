import Modifier from 'ember-modifier';
import { scheduleOnce } from '@ember/runloop';
import { registerDestructor } from '@ember/destroyable';

export default class ViewTransitionModifier extends Modifier {
  previousValues = null;
  element = null;
  isInitialRender = true;

  constructor(owner, args) {
    super(owner, args);
    // Ensure we clean up if the element is removed
    registerDestructor(this, () => {
      this.previousValues = [];
      this.element = null;
    });
  }

  checkForChanges(watchedValues, didChange) {
    if (this.isInitialRender) return true;

    const hasDidChange = didChange !== 'undefined' && didChange !== null;
    const hasWatchedValues = watchedValues.length > 0;

    if (hasDidChange && hasWatchedValues) {
      throw new Error('The ViewTransition modifier requires either didChange or watchedValues. Both cannot be provided.');
    }

    if (!hasDidChange && !hasWatchedValues) {
      throw new Error('The ViewTransition modifier requires either didChange or watchedValues. One must be provided.');
    }

    if (hasDidChange) {
      if (typeof didChange === 'function') return didChange();
      if (typeof didChange === 'boolean') return didChange;
      throw new Error('didChange must be a function or a boolean');
    }

    return watchedValues.some((value, i) => value !== this.previousValues[i]);
  }

  modify(element, watchedValues, { transitionName = 'none', didChange, onExecute }) {
    if (!document.startViewTransition) return;

    if (!this.checkForChanges(watchedValues, didChange)) return;

    this.element = element;
    this.previousValues = watchedValues;

    if (this.isInitialRender) {
      this.isInitialRender = false;
      return;
    }

    this.element.style.viewTransitionName = transitionName;

    const transition = document.startViewTransition(() => {
      // technically, the root cause of the eventual DOM changes should happen within this callback,
      // but because the actual rendering of the changes occurs later, we can also presumably assume
      // that changes will arrive after render.  Therefore, onExecute is technically the correct
      // way to do it according to the spec, but it may not be necessary. Both are provided for now.
      if (onExecute) {
        return onExecute();
      }

      // if onExecute is not provided, simply wait until the render is finished
      // eslint-disable-next-line ember/no-runloop
      return new Promise((resolve) => scheduleOnce('afterRender', resolve));
    });

    // cleanup the view transition name when the transition is finished
    transition.finished.finally(() => {
      if (this.element) {
        this.element.style.viewTransitionName = 'none';
      }
    });
  }
}
