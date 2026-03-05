import { helper } from '@ember/component/helper';

export default helper(function preventDefault([callback, ...args]) {
  return function(event) {
    if (event && typeof event.preventDefault === 'function') {
      event.preventDefault();
    }

    if (typeof callback === 'function') {
      // We spread the args first, then pass the event as the final argument
      return callback(...args, event);
    }
  };
});
