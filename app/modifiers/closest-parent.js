import { modifier } from 'ember-modifier';

export default modifier((element, [selector]) => {
  return element.closest(selector);
});
