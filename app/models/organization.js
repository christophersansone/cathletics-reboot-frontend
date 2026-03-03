import Model, { attr, hasMany } from '@ember-data/model';

export default class OrganizationModel extends Model {
  @attr('string') name;
  @attr('string') slug;
  @attr('string') timeZone;

  @hasMany('organization-membership', { async: true, inverse: 'organization' }) organizationMemberships;
  @hasMany('activity-type', { async: true, inverse: 'organization' }) activityTypes;
}
