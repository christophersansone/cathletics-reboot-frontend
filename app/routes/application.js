import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service session;
  @service router;

  redirect() {
    if (!this.session.isAuthenticated) {
      this.router.transitionTo('login');
    }
  }

  async beforeModel() {
    if (this.session.isAuthenticated) {
      await this.session.loadCurrentUser();
    }
  }
}
