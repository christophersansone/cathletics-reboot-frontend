import { DateTime } from 'luxon';

/**
 * For "remove all future occurrences": last calendar date (in `timeZone`) that should remain
 * as `recurs_until`, given the first event start and an occurrence instant to truncate before.
 *
 * @param {object} opts
 * @param {string} opts.eventStartAtIso - DB `start_at` / first occurrence (ISO UTC)
 * @param {string} opts.occurrenceStartAtIso - first occurrence to remove (ISO UTC)
 * @param {string} opts.rrule - pattern only (FREQ=…), no UNTIL
 * @param {string} opts.timeZone - IANA zone for series
 * @returns {string|null} ISO date `yyyy-MM-dd` for `recursUntil`, or null to clear recurrence entirely
 */
export function recursUntilDateBeforeOccurrence({ eventStartAtIso, occurrenceStartAtIso, rrule, timeZone }) {
  const tz = timeZone || 'UTC';
  const r = (rrule || '').toUpperCase();
  const step = r.includes('FREQ=DAILY')
    ? { days: 1 }
    : r.includes('FREQ=MONTHLY')
      ? { months: 1 }
      : { weeks: 1 };

  const target = DateTime.fromISO(occurrenceStartAtIso, { zone: 'utc' });
  let t = DateTime.fromISO(eventStartAtIso, { zone: 'utc' }).setZone(tz);
  const targetUtc = target.toUTC();

  if (t.toUTC() >= targetUtc) {
    return null;
  }

  while (true) {
    const next = t.plus(step);
    if (next.toUTC() >= targetUtc) {
      break;
    }
    t = next;
  }
  return t.toISODate();
}
