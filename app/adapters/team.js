import ApplicationAdapter from './application';

export default class TeamAdapter extends ApplicationAdapter {
  async associatedMembersFor(teamId) {
    const url = `${this.buildURL('team', teamId)}/associated_members`;
    const payload = await this.ajax(url, 'GET');
    this.store.pushPayload(payload);
    const ids = (payload.data || []).map((d) => String(d.id));
    const models = ids.map((id) => this.store.peekRecord('team-membership', id)).filter(Boolean);
    return models;
  }

}
