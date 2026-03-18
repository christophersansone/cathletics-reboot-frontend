import Model, { attr, belongsTo, hasMany } from '@ember-data/model';

export default class TeamModel extends Model {
  @attr('string') name;

  @belongsTo('league', { async: true, inverse: 'teams' }) league;
  @hasMany('team-membership', { async: true, inverse: 'team' }) teamMemberships;
  @hasMany('scheduled-event', { async: true, inverse: null }) scheduledEvents;
}
