import { DateTime } from 'luxon';

/**
 * Converts a Luxon DateTime (typically UTC from the API) to the event's
 * display zone. Returns null if either argument is missing.
 */
export function toEventZone(dt, zone) {
  if (!dt || !zone) return dt || null;
  return dt.setZone(zone);
}

/**
 * Formats a Luxon DateTime for human display.
 *   "Oct 1, 2026 at 3:00 PM"
 */
export function formatDateTime(dt) {
  if (!dt) return '';
  return dt.toFormat("LLL d, yyyy 'at' h:mm a");
}

/**
 * Formats a Luxon DateTime as date only.
 *   "Oct 1, 2026"
 */
export function formatDate(dt) {
  if (!dt) return '';
  if (typeof dt === 'string') {
    dt = DateTime.fromISO(dt);
  }
  return dt.toFormat('LLL d, yyyy');
}

/**
 * Formats a Luxon DateTime as time only.
 *   "3:00 PM"
 */
export function formatTime(dt) {
  if (!dt) return '';
  return dt.toFormat('h:mm a');
}

/**
 * Returns the short zone abbreviation (e.g., "CDT", "EST").
 */
export function zoneAbbr(dt) {
  if (!dt) return '';
  return dt.toFormat('ZZZZ');
}

/**
 * Checks whether the event's zone matches the user's local zone
 * at the given point in time.
 */
export function isSameAsLocal(dt) {
  if (!dt) return true;
  const localOffset = DateTime.local().setZone(dt.zoneName).offset;
  return dt.offset === localOffset;
}

/**
 * Converts a UTC Luxon DateTime to the event zone and returns a
 * display-ready object with all the pieces a template might need.
 */
export function formatEventDateTime(dt, zone) {
  if (!dt || !zone) return null;

  const eventDt = toEventZone(dt, zone);
  const localDt = dt.setZone('local');
  const sameZone = eventDt.offset === localDt.offset;

  return {
    formatted: formatDateTime(eventDt),
    zone: zoneAbbr(eventDt),
    sameAsLocal: sameZone,
    localFormatted: sameZone ? null : formatDateTime(localDt),
    localTime: sameZone ? null : formatTime(localDt),
    raw: eventDt,
  };
}

/**
 * For <input type="datetime-local">: converts a UTC Luxon DateTime to
 * the event zone and formats as the value string the input expects.
 */
export function toLocalInputValue(dt, zone) {
  if (!dt || !zone) return '';
  return toEventZone(dt, zone).toFormat("yyyy-MM-dd'T'HH:mm");
}

/**
 * For <input type="datetime-local">: parses the input value string
 * as a time in the event zone and converts to a UTC Luxon DateTime.
 */
export function fromLocalInputValue(value, zone) {
  if (!value || !zone) return null;
  return DateTime.fromISO(value, { zone }).toUTC();
}

/**
 * Calendar date (YYYY-MM-dd) for scheduled-event `exdates`: maps an occurrence
 * instant (ISO UTC string or DateTime-like) to the event IANA zone.
 */
export function occurrenceStartToExdate(startAt, ianaTimeZone) {
  const zone = ianaTimeZone || 'UTC';
  const iso =
    typeof startAt === 'string'
      ? startAt
      : startAt?.toISO?.() ?? startAt?.toISOString?.() ?? '';
  if (!iso) return '';
  const dt = DateTime.fromISO(String(iso), { zone: 'utc' });
  if (!dt.isValid) return '';
  return dt.setZone(zone).toISODate();
}
