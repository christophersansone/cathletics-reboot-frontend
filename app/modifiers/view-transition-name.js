import { modifier} from 'ember-modifier';

export default modifier(function viewTransitionName(element, [transitionName]) {
  if (!document.startViewTransition) return;

  if (transitionName) {
    element.style.viewTransitionName = transitionName;
  } else {
    element.style.removeProperty('view-transition-name');
  }

  return () => {
    element.style.removeProperty('view-transition-name');
  };
});
