import ICAL from 'ical.js';

/**
 * Parses an iCalendar (text/calendar) string and returns an array of occurrence
 * objects suitable for the schedule tab: { title, startAt, endAt, timeZone, eventId, cancelled, cancellationReason, isRecurring }.
 * Uses X-EVENT-ID, X-TZID, X-RECURRING, STATUS, X-CANCELLATION-REASON from our backend when present.
 */
export function parseIcalToOccurrences(icalString) {
  if (!icalString || typeof icalString !== 'string') return [];

  const comp = ICAL.Component.fromString(icalString);
  const vevents = comp.getAllSubcomponents('vevent');
  const results = [];

  for (const vevent of vevents) {
    const event = new ICAL.Event(vevent);
    const summary = event.summary || '';
    const start = event.startDate;
    const end = event.endDate;
    if (!start || !end) continue;

    const startJS = start.toJSDate();
    const endJS = end.toJSDate();
    const startAt = startJS.toISOString();
    const endAt = endJS.toISOString();

    let timeZone = 'UTC';
    const tzProp = vevent.getFirstProperty('x-tzid') || vevent.getFirstProperty('X-TZID');
    if (tzProp) timeZone = tzProp.getFirstValue();

    let eventId = '';
    const idProp = vevent.getFirstProperty('x-event-id') || vevent.getFirstProperty('X-EVENT-ID');
    if (idProp) eventId = String(idProp.getFirstValue());

    // ical.js property names are lowercase in jCal (see ICAL.Component#getFirstProperty).
    let cancelled = false;
    const statusRaw = vevent.getFirstPropertyValue('status');
    if (statusRaw != null && String(statusRaw).toUpperCase().trim() === 'CANCELLED') {
      cancelled = true;
    }
    let cancellationReason = '';
    const reasonRaw = vevent.getFirstPropertyValue('x-cancellation-reason');
    if (reasonRaw != null) cancellationReason = String(reasonRaw);

    let isRecurring = false;
    const recProp = vevent.getFirstProperty('x-recurring') || vevent.getFirstProperty('X-RECURRING');
    if (recProp) isRecurring = String(recProp.getFirstValue() || '').toLowerCase() === 'true';

    results.push({
      title: summary,
      startAt,
      endAt,
      timeZone,
      eventId,
      cancelled,
      cancellationReason,
      isRecurring,
    });
  }

  results.sort((a, b) => a.startAt.localeCompare(b.startAt));
  return results;
}
