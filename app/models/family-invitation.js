import Model, { attr, belongsTo } from '@ember-data/model';

export default class FamilyInvitationModel extends Model {
  @attr('string') role;
  @attr('string') token;
  @attr('date') expiresAt;
  @attr('date') createdAt;

  @belongsTo('family', { async: true, inverse: 'familyInvitations' }) family;
  @belongsTo('user', { async: true, inverse: null }) createdBy;
}
