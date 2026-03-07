import Model, { attr, belongsTo } from '@ember-data/model';

export default class TeamMembershipModel extends Model {
  @attr('string') role;
  @attr('string') uniformNumber;
  @attr('string') position;

  @belongsTo('team', { async: true, inverse: 'teamMemberships' }) team;
  @belongsTo('user', { async: true, inverse: null }) user;
}
