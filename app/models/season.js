import Model, { attr, belongsTo, hasMany } from '@ember-data/model';

export default class SeasonModel extends Model {
  @attr('string') name;
  @attr('string') startDate;
  @attr('string') endDate;
  @attr('luxon-datetime') registrationStartAt;
  @attr('luxon-datetime') registrationEndAt;
  @attr('boolean') registrationOpen;
  @attr('string') timeZone;
  @attr('string') effectiveTimeZone;

  @belongsTo('activity-type', { async: true, inverse: 'seasons' }) activityType;
  @hasMany('league', { async: true, inverse: 'season' }) leagues;
}
