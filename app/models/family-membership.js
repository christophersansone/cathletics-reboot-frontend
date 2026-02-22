import Model, { attr, belongsTo } from '@ember-data/model';

export default class FamilyMembershipModel extends Model {
  @attr('string') role;

  @belongsTo('family', { async: true, inverse: 'familyMemberships' }) family;
  @belongsTo('user', { async: true, inverse: 'familyMemberships' }) user;
}
