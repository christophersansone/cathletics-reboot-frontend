import Modifier from 'ember-modifier';
import { scheduleOnce } from '@ember/runloop';
import { registerDestructor } from '@ember/destroyable';
import { service } from '@ember/service';
import config from '../config/environment';

// Add this modifier to a top-level element in your application template.
// It hooks into the router events to apply the proper view transition.

// Define custom transitions in /config/environment.js under APP.routeTransitions.
// It should be an array of objects with a "to" (route name), and / or "from" (route name),
// or a test() function that returns a boolean, given the transition object.
// The object should have a "transition" property that is a string of the view transition name to use.
// The first matching entry is used, so the order in which they are defined is important.
const CUSTOM_TRANSITIONS = config?.APP?.routeTransitions;

export default class RouterViewTransitionModifier extends Modifier {
  @service router;

  element = null;
  isTransitionPending = false;

  constructor(owner, args) {
    super(owner, args);
    registerDestructor(this, () => {
      this.removeRouterEvents();
      this.element = null;
    });
  }

  initializeRouterEvents() {
    this._routeWillChange = (transition) => {
      if (transition.isAborted || this.isTransitionPending || !this.element) {
        return;
      }

      const transitionName = this.getTransitionName(transition);
      if (!transitionName) return;

      this.element.style.viewTransitionName = transitionName;

      // abort the transition so that we retry it within startViewTransition()
      transition.abort();

      const vt = document.startViewTransition(async () => {
        this.isTransitionPending = true;

        try {
          // retry the transition so that we can capture the "old" state
          const newTransition = transition.retry();
          // wait for the new transition to finish rendering
          try {
            await newTransition;
          } catch (error) {
            // a TransitionAborted error is expected and should be ignored
            if (error.name === 'TransitionAborted') return;
            throw error;
          }

          // return once render is finished
          // eslint-disable-next-line ember/no-runloop
          return new Promise(resolve => scheduleOnce('afterRender', resolve));
        } finally {
          this.isTransitionPending = false;
        }
      });

      // cleanup the view transition name
      vt.finished.finally(() => {
        if (this.element) {
          this.element.style.removeProperty('viewTransitionName');
        }
      });
    }

    this.router.on('routeWillChange', this._routeWillChange);
  }

  removeRouterEvents() {
    if (this._routeWillChange) {
      this.router.off('routeWillChange', this._routeWillChange);
      this._routeWillChange = null;
    }
  }

  getTransitionName(routeTransition) {
    return this.customTransitionFor(routeTransition) || this.defaultTransitionFor(routeTransition);
  }

  customTransitionFor(routeTransition) {
    if (!CUSTOM_TRANSITIONS) return;
    const { to, from } = routeTransition;
    const entry = CUSTOM_TRANSITIONS.find((t) => {
      if (t.test) {
        return t.test(routeTransition);
      } else if (t.to && t.from) {
        return t.to === to.name && t.from === from.name;
      } else if (t.to) {
        return t.to === to.name;
      } else if (t.from) {
        return t.from === from.name;
      } else {
        return false;
      }
    });

    return entry?.transition;
  }

  defaultTransitionFor(routeTransition) {
    const fromRoute = routeTransition.from?.name ?? '';
    const toRoute = routeTransition.to?.name ?? '';
    const fromRouteName = this.trimIndex(fromRoute);
    const toRouteName = this.trimIndex(toRoute);
    if (fromRouteName === toRouteName) {
      return 'fade';
    } else if (toRouteName.startsWith(fromRouteName)) {
      // navigating from parent to child -- animate forward (left)
      return 'slide-left';
    } else if (fromRouteName.startsWith(toRouteName)) {
      // navigating from child to parent -- animate back (right)
      return 'slide-right';
    }
    return 'fade';
  }

  trimIndex(routeName) {
    let routeParts = routeName.split('.');
    if (routeParts[routeParts.length - 1] === 'index') {
      routeParts.pop();
    }
    return routeParts.join('.');
  }

  modify(element) {
    if (!document.startViewTransition) return;

    if (!this.element) {
      this.element = element;
      this.initializeRouterEvents();
    }
  }
}
