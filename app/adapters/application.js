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

  async ajax(...args) {
    try {
      return await super.ajax(...args);
    } catch (error) {
      if (this._isUnauthorized(error) && this.session.refreshToken) {
        let refreshed = await this.session.refreshAccessToken();
        if (refreshed) {
          return super.ajax(...args);
        }
      }

      if (this._isUnauthorized(error) && this.session.isAuthenticated) {
        this.session.invalidate();
      }

      throw error;
    }
  }

  _isUnauthorized(error) {
    return error?.errors?.some((e) => String(e.status) === '401');
  }
}
