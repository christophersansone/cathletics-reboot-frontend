import ApplicationAdapter from './application';

export default class OrganizationAdapter extends ApplicationAdapter {

  async join(organization) {
    const url = `${this.buildURL('organization', organization.slug)}/join`;
    const response = await this.ajax(url, 'POST');
    this.store.pushPayload(response);
    return organization;
  }
}
