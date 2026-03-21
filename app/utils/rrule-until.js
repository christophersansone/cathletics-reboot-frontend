/**
 * Appends UNTIL to an rrule string so the recurrence ends at or before the given datetime.
 * Used when "removing all future" or "editing all future" (end the original series).
 *
 * @param {string} rrule - e.g. "FREQ=WEEKLY;BYDAY=TU,TH"
 * @param {string} lastOccurrenceEndIso - ISO8601 datetime; series will end at or before this (typically occurrence start - 1 second)
 * @returns {string} rrule with UNTIL=YYYYMMDDTHHMMSSZ appended
 */
export function appendRruleUntil(rrule, lastOccurrenceEndIso) {
  if (!rrule || typeof rrule !== 'string') return rrule;
  const date = new Date(lastOccurrenceEndIso);
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');
  const h = String(date.getUTCHours()).padStart(2, '0');
  const min = String(date.getUTCMinutes()).padStart(2, '0');
  const s = String(date.getUTCSeconds()).padStart(2, '0');
  const until = `${y}${m}${d}T${h}${min}${s}Z`;
  const trimmed = rrule.replace(/\s*$/, '').replace(/;?\s*UNTIL=[^;]*/gi, '');
  const sep = trimmed.endsWith(';') ? '' : ';';
  return `${trimmed}${sep}UNTIL=${until}`;
}
