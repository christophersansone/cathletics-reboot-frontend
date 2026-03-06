import Service from '@ember/service';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import config from 'frontend/config/environment';
import { task } from 'ember-concurrency';

export default class SessionService extends Service {
  @service store;
  @service router;

  @tracked accessToken = null;
  @tracked refreshToken = null;
  @tracked currentUser = null;
  @tracked currentOrgId = null;
  @tracked isAuthenticated = false;
  @tracked attemptedTransition = null;

  constructor() {
    super(...arguments);
    this.restoreSession();
  }

  restoreSession() {
    let token = localStorage.getItem('cathletics:accessToken');
    let refresh = localStorage.getItem('cathletics:refreshToken');
    if (token) {
      this.accessToken = token;
      this.refreshToken = refresh;
      this.isAuthenticated = true;
    }
    this.currentOrgId = localStorage.getItem('cathletics:orgId');
  }

  async signup({ firstName, lastName, email, password }) {
    let response = await fetch(`${config.APP.apiHost}/${config.APP.apiNamespace}/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: JSON.stringify({
        data: {
          type: 'users',
          attributes: { firstName, lastName, email, password },
        },
      }),
    });

    if (!response.ok) {
      let body = await response.json().catch(() => ({}));
      let messages = body.errors?.map((e) => e.detail || e.title).join(', ');
      throw new Error(messages || 'Signup failed');
    }

    await this.authenticate(email, password);
  }

  async authenticate(email, password) {
    let response = await fetch(`${config.APP.apiHost}/oauth/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        grant_type: 'password',
        username: email,
        password: password,
        client_id: config.APP.oauthClientId,
      }),
    });

    if (!response.ok) {
      let body = await response.json().catch(() => ({}));
      throw new Error(body.error_description || 'Invalid email or password');
    }

    let data = await response.json();
    this._setTokens(data);

    await this.loadCurrentUser();
  }

  async refreshAccessToken() {
    if (!this.refreshToken) return false;
    const task = this.refreshAccessTokenTask;
    if (task.isRunning) {
      return await task.last;
    } else {
      return await task.perform();
    }
  }

  refreshAccessTokenTask = task({ drop: true }, async () => {
    try {
      let response = await fetch(`${config.APP.apiHost}/oauth/token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          grant_type: 'refresh_token',
          refresh_token: this.refreshToken,
          client_id: config.APP.oauthClientId,
        }),
      });

      if (!response.ok) return false;

      let data = await response.json();
      this._setTokens(data);
      await this.loadCurrentUser();
      return true;
    } catch {
      return false;
    }
  });

  _setTokens(data) {
    this.accessToken = data.access_token;
    this.refreshToken = data.refresh_token;
    this.isAuthenticated = true;

    localStorage.setItem('cathletics:accessToken', data.access_token);
    localStorage.setItem('cathletics:refreshToken', data.refresh_token);
  }

  setOrganization(org) {
    this.currentOrgId = org.id;
    localStorage.setItem('cathletics:orgId', org.id);
  }

  clearOrganization() {
    this.currentOrgId = null;
    localStorage.removeItem('cathletics:orgId');
  }

  async loadCurrentUser() {
    if (!this.isAuthenticated) return null;
    if (this.currentUser) return this.currentUser;

    try {
      let response = await fetch(`${config.APP.apiHost}/${config.APP.apiNamespace}/me`, {
        headers: { 'Authorization': `Bearer ${this.accessToken}` },
      });

      if (!response.ok) throw new Error('Failed to load user');

      let payload = await response.json();
      this.store.pushPayload(payload);
      this.currentUser = this.store.peekRecord('user', payload.data.id);
    } catch {
      this.invalidate();
    }
  }

  invalidate() {
    this.accessToken = null;
    this.refreshToken = null;
    this.currentUser = null;
    this.currentOrgId = null;
    this.isAuthenticated = false;

    localStorage.removeItem('cathletics:accessToken');
    localStorage.removeItem('cathletics:refreshToken');
    localStorage.removeItem('cathletics:orgId');

    this.router.transitionTo('login');
  }
}
