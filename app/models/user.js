import Model, { attr, hasMany } from '@ember-data/model';

export default class UserModel extends Model {
  @attr('string') firstName;
  @attr('string') lastName;
  @attr('string') email;
  @attr('string') nickname;
  @attr('string') dateBirth;
  @attr('number') gradeLevel;
  @attr('string') gender;
  @attr('string') fullName;
  @attr('string') displayName;

  @hasMany('family-membership', { async: true, inverse: 'user' }) familyMemberships;
  @hasMany('organization-membership', { async: true, inverse: 'user' }) organizationMemberships;
}
