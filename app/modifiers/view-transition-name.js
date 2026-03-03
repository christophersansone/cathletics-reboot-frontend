import { modifier} from 'ember-modifier';

export default modifier(function viewTransitionName(element, [transitionName]) {
  if (!document.startViewTransition) return;

  element.style.viewTransitionName = transitionName;

  return () => {
    element.style.viewTransitionName = 'none';
  };
});
