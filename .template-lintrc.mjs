export default {
  extends: 'recommended',
  plugins: ['ember-scoped-css/src/template-lint/plugin'],
  rules: {
    'scoped-class-helper': 'error',
    'no-forbidden-elements': ['meta', 'html', 'script'], // style removed
  },
};
