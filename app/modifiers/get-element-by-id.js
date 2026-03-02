import { modifier } from 'ember-modifier';

export default modifier((_, [id]) => {
  return window.document.getElementById(id);
});
