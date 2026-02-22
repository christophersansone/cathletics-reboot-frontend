import Model, { attr, belongsTo } from '@ember-data/model';

export default class OrganizationMembershipModel extends Model {
  @attr('string') role;

  @belongsTo('organization', { async: true, inverse: 'organizationMemberships' }) organization;
  @belongsTo('user', { async: true, inverse: 'organizationMemberships' }) user;
}
