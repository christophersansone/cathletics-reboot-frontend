import ApplicationAdapter from './application';

export default class ScheduledEventAdapter extends ApplicationAdapter {
  /**
   * Fetches the schedule as an iCal feed for the given schedulable.
   * Uses flat URL with query params so it works for any schedulable type (Team, etc.).
   * Returns raw iCal string (text/calendar); caller should parse with parseIcalToOccurrences().
   *
   * @param {Object} opts
   * @param {string} opts.schedulableType - e.g. 'Team'
   * @param {string} opts.schedulableId - id of the schedulable
   * @param {string} opts.from - ISO date range start
   * @param {string} opts.to - ISO date range end
   * @returns {Promise<string>} iCal document string
   */
  async occurrences({ schedulableType, schedulableId, from, to }) {
    const params = new URLSearchParams({
      schedulable_type: schedulableType,
      schedulable_id: schedulableId,
      from: from ?? '',
      to: to ?? '',
    });
    const url = `${this.host}/${this.namespace}/scheduled_event_occurrences?${params}`;
    const response = await this.requestWithAuth(url, 'GET');
    if (!response.ok) {
      throw new Error(`Schedule request failed: ${response.status}`);
    }
    return await response.text();
  }
}
