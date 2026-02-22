export function initialize(appInstance) {
  appInstance.lookup('service:theme');
}

export default {
  name: 'theme',
  initialize,
};
