import Model, { attr, belongsTo, hasMany } from '@ember-data/model';

export default class SeasonModel extends Model {
  @attr('string') name;
  @attr('string') startDate;
  @attr('string') endDate;
  @attr('string') registrationStartAt;
  @attr('string') registrationEndAt;
  @attr('boolean') registrationOpen;

  @belongsTo('activity-type', { async: true, inverse: 'seasons' }) activityType;
  @hasMany('league', { async: true, inverse: 'season' }) leagues;
}
