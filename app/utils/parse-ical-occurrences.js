import ICAL from 'ical.js';

const PARTSTAT_TO_RESPONSE = {
  ACCEPTED: 'yes',
  DECLINED: 'no',
  TENTATIVE: 'maybe',
};

function parseAttendeeRsvp(vevent) {
  const prop = vevent.getFirstProperty('attendee');
  if (!prop) return null;

  const partstat = (prop.getParameter('partstat') || '').toUpperCase();
  const response = PARTSTAT_TO_RESPONSE[partstat] ?? null;
  const userId = prop.getParameter('x-user-id') || null;
  const rsvpId = prop.getParameter('x-rsvp-id') || null;

  return { response, userId, rsvpId };
}

function parseRsvpCounts(vevent) {
  const yes = parseInt(vevent.getFirstPropertyValue('x-rsvp-yes-count'), 10) || 0;
  const no = parseInt(vevent.getFirstPropertyValue('x-rsvp-no-count'), 10) || 0;
  const maybe = parseInt(vevent.getFirstPropertyValue('x-rsvp-maybe-count'), 10) || 0;
  return { yes, no, maybe };
}

/**
 * Parses an iCalendar (text/calendar) string and returns an array of occurrence objects suitable
 * for the schedule tab. Uses standard ATTENDEE/PARTSTAT for the current user's RSVP, and custom
 * X-RSVP-MODE / X-RSVP-*-COUNT properties for mode and summary counts.
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

    const rsvpModeRaw = vevent.getFirstPropertyValue('x-rsvp-mode');
    const rsvpMode = rsvpModeRaw ? String(rsvpModeRaw) : 'none';

    const myRsvp = rsvpMode !== 'none' ? parseAttendeeRsvp(vevent) : null;
    const rsvpCounts = rsvpMode !== 'none' ? parseRsvpCounts(vevent) : { yes: 0, no: 0, maybe: 0 };

    results.push({
      title: summary,
      startAt,
      endAt,
      timeZone,
      eventId,
      cancelled,
      cancellationReason,
      isRecurring,
      rsvpMode,
      myRsvp,
      rsvpCounts,
    });
  }

  results.sort((a, b) => a.startAt.localeCompare(b.startAt));
  return results;
}
