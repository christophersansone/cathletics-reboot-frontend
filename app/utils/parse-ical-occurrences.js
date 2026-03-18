import ICAL from 'ical.js';

/**
 * Parses an iCalendar (text/calendar) string and returns an array of occurrence
 * objects suitable for the schedule tab: { title, startAt, endAt, timeZone, eventId }.
 * Uses X-EVENT-ID and X-TZID from our backend when present.
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

    results.push({
      title: summary,
      startAt,
      endAt,
      timeZone,
      eventId,
      cancelled: false,
    });
  }

  results.sort((a, b) => a.startAt.localeCompare(b.startAt));
  return results;
}
