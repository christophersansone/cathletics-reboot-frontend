
import { helper } from '@ember/component/helper';

export default helper(([id]) => {
  return window.document.getElementById(id);
});
