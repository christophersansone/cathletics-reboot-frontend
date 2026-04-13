import Model, { attr, belongsTo } from '@ember-data/model';

export default class ScheduledEventModel extends Model {
  @attr('string') title;
  @attr('string') description;
  @attr('luxon-datetime') startAt;
  @attr('luxon-datetime') endAt;
  @attr('string') timeZone;
  @attr('boolean') allDay;
  @attr('string') rrule;
  /** Last calendar day (event TZ) the series may include; with `rrule`, defines recurrence. */
  @attr('date-only') recursUntil;
  @attr() exdates; // array of ISO date strings
  @attr() cancelledOccurrences; // array of { start_at, reason }
  @attr('date') cancelledFrom;
  @attr('string') cancellationReason;
  @attr('string') rsvpMode;

  @belongsTo('schedulable', { polymorphic: true, async: true, inverse: null }) schedulable;
}
