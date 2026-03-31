import Route from '@ember/routing/route';
import { service } from '@ember/service';

const PUBLIC_ROUTES = ['login', 'signup', 'join-family'];

export default class ApplicationRoute extends Route {
  @service session;
  @service router;

  async beforeModel(transition) {
    let targetName = transition.to?.name || '';
    let isPublic = PUBLIC_ROUTES.some((r) => targetName === r || targetName.startsWith(r + '.'));

    if (this.session.isAuthenticated) {
      await this.session.loadCurrentUser();
      if (!this.session.isAuthenticated) {
        this.router.transitionTo('login');
        return;
      }
    }

    if (!this.session.isAuthenticated && !isPublic) {
      this.session.attemptedTransition = transition;
      this.router.transitionTo('login');
    }
  }
}
