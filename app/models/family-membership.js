import Model, { attr, belongsTo } from '@ember-data/model';

export default class FamilyMembershipModel extends Model {
  @attr('string') role;

  get canManage() {
    return this.role === 'parent' || this.role === 'guardian';
  }

  @belongsTo('family', { async: true, inverse: 'familyMemberships' }) family;
  @belongsTo('user', { async: true, inverse: 'familyMemberships' }) user;
}
