import Model, { attr, belongsTo } from '@ember-data/model';

export default class ScheduledEventRsvpModel extends Model {
  @attr('string') response;
  @attr('luxon-datetime') occurrenceStartAt;
  @attr('string') note;
  @attr('luxon-datetime') createdAt;
  @attr('luxon-datetime') updatedAt;

  @belongsTo('scheduled-event', { async: true, inverse: null }) scheduledEvent;
  @belongsTo('user', { async: true, inverse: null }) user;
  @belongsTo('user', { async: true, inverse: null }) respondedBy;
}
