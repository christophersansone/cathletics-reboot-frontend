import ApplicationAdapter from './application';
import { service } from '@ember/service';

export default class FamilyInvitationAdapter extends ApplicationAdapter {
  @service store;

  async accept(familyInvitation) {
    const url = `${this.buildURL('family-invitation', familyInvitation.token)}/accept`;
    const response = await this.ajax(url, 'POST', { data: null });
    this.store.pushPayload(response);
    return this.store.peekRecord('user', response.data.id);
  }
}
