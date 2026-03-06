import ApplicationAdapter from './application';
import { service } from '@ember/service';

export default class FamilyAdapter extends ApplicationAdapter {
  @service store;

  async createChild(family, attrs) {
    const url = `${this.buildURL('child')}`;
    const payload = {
      data: {
        type: 'users',
        attributes: {
          firstName: attrs.firstName,
          lastName: attrs.lastName,
          dateOfBirth: attrs.dateOfBirth,
          gradeLevel: attrs.gradeLevel,
          gender: attrs.gender,
        },
        relationships: {
          family: {
            data: { type: 'families', id: family.id },
          },
        },
      },
    };

    const response = await this.ajax(url, 'POST', { data: payload });
    this.store.pushPayload(response);
    return this.store.peekRecord('user', response.data.id);
  }
}
