import Model, { attr, belongsTo } from '@ember-data/model';

export default class TeamMembershipModel extends Model {
  @attr('string') role;

  @belongsTo('team', { async: true, inverse: 'teamMemberships' }) team;
  @belongsTo('user', { async: true, inverse: null }) user;
}
