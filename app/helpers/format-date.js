import { helper } from '@ember/component/helper';
import { formatDate } from 'frontend/utils/datetime';

export default helper(function ([value]) {
  return formatDate(value);
});
