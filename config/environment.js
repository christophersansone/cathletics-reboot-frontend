'use strict';

require('dotenv').config();

module.exports = function (environment) {
  const ENV = {
    modulePrefix: 'frontend',
    environment,
    rootURL: '/',
    locationType: 'history',
    EmberENV: {
      EXTEND_PROTOTYPES: false,
      FEATURES: {},
    },

    APP: {
      apiHost: 'http://localhost:3000',
      apiNamespace: 'api/v1',
      oauthClientId: process.env.OAUTH_CLIENT_ID || '',
      routeTransitions: [
        { from: 'login', to: 'signup', transition: 'none' },
        { from: 'signup', to: 'login', transition: 'none' },
      ]
    },
  };

  if (environment === 'development') {
  }

  if (environment === 'test') {
    ENV.locationType = 'none';
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;
    ENV.APP.rootElement = '#ember-testing';
    ENV.APP.autoboot = false;
  }

  if (environment === 'production') {
    ENV.APP.apiHost = '';
  }

  return ENV;
};
