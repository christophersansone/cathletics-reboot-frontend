import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class MyFamilyIndexRoute extends Route {
  @service store;
  @service session;
  @service router;

  async model() {
    return await this.store.query('family', {
      user_id: this.session.currentUser.id,
    });
  }

  /*redirect(families) {
    if (families.length === 1) {
      return this.router.transitionTo('my-family.family', families[0].id);
    }
  }*/
}
