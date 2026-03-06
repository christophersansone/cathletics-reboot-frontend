import Model, { attr, hasMany } from '@ember-data/model';

export default class FamilyModel extends Model {
  @attr('string') name;

  @hasMany('family-membership', { async: true, inverse: 'family' }) familyMemberships;
  @hasMany('family-invitation', { async: true, inverse: 'family' }) familyInvitations;
}
