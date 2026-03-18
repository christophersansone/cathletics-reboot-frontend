import Model, { attr, belongsTo } from '@ember-data/model';

export default class ScheduledEventModel extends Model {
  @attr('string') title;
  @attr('string') description;
  @attr('luxon-datetime') startAt;
  @attr('luxon-datetime') endAt;
  @attr('string') timeZone;
  @attr('boolean') allDay;
  @attr('string') rrule;
  @attr() exdates; // array of ISO date strings

  @belongsTo('schedulable', { polymorphic: true, async: true, inverse: null }) schedulable;
}
