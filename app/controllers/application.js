import Controller from '@ember/controller';
import { service } from '@ember/service';

const PUBLIC_ROUTES = ['login', 'signup', 'join-family', 'join'];
const EXCLUDED_PREFIXES = ['orgs.'];

export default class ApplicationController extends Controller {
  @service router;
  @service session;

  get isMemberRoute() {
    const name = this.router.currentRouteName || '';
    if (!this.session.isAuthenticated) return false;
    if (EXCLUDED_PREFIXES.some((p) => name.startsWith(p))) return false;
    return !PUBLIC_ROUTES.some((p) => name === p || name.startsWith(p + '.'));
  }
}
