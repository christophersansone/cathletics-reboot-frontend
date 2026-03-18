import ApplicationAdapter from './application';

export default class UserAdapter extends ApplicationAdapter {

  async me() {
    const url = `${this.buildURL()}/me`;
    const response = await this.ajax(url, 'GET');
    this.store.pushPayload(response);
    return this.store.peekRecord('user', response.data.id);
  }
}
