import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import config from 'frontend/config/environment';

export default class SessionService extends Service {
  @service store;
  @service router;

  @tracked accessToken = null;
  @tracked refreshToken = null;
  @tracked currentUser = null;
  @tracked isAuthenticated = false;

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
    this.accessToken = data.access_token;
    this.refreshToken = data.refresh_token;
    this.isAuthenticated = true;

    localStorage.setItem('cathletics:accessToken', data.access_token);
    localStorage.setItem('cathletics:refreshToken', data.refresh_token);

    await this.loadCurrentUser();
  }

  async loadCurrentUser() {
    try {
      let response = await fetch(`${config.APP.apiHost}/${config.APP.apiNamespace}/me`, {
        headers: { 'Authorization': `Bearer ${this.accessToken}` },
      });

      if (!response.ok) throw new Error('Failed to load user');

      let payload = await response.json();
      this.store.pushPayload('user', payload);
      this.currentUser = this.store.peekRecord('user', payload.data.id);
    } catch {
      this.invalidate();
    }
  }

  invalidate() {
    this.accessToken = null;
    this.refreshToken = null;
    this.currentUser = null;
    this.isAuthenticated = false;

    localStorage.removeItem('cathletics:accessToken');
    localStorage.removeItem('cathletics:refreshToken');

    this.router.transitionTo('login');
  }
}
