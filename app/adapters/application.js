import JSONAPIAdapter from '@ember-data/adapter/json-api';
import { inject as service } from '@ember/service';
import config from 'frontend/config/environment';

export default class ApplicationAdapter extends JSONAPIAdapter {
  @service session;

  host = config.APP.apiHost;
  namespace = config.APP.apiNamespace;

  get headers() {
    let headers = { 'Content-Type': 'application/vnd.api+json' };
    let token = this.session.accessToken;
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
  }

  handleResponse(status, headers, payload, requestData) {
    if (status === 401 && this.session.isAuthenticated) {
      this.session.invalidate();
    }
    return super.handleResponse(status, headers, payload, requestData);
  }
}
