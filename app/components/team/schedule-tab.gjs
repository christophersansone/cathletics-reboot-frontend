import Component from '@glimmer/component';
import { tracked, args, service, on } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { DateTime } from 'luxon';
import { UiCard, UiButton } from 'frontend/components/ui';
import { Await, Errors } from 'frontend/utils/stdlib';
import FormattedTime from 'frontend/components/formatted-time';
import { parseIcalToOccurrences } from 'frontend/utils/parse-ical-occurrences';
import ScheduledEventModalComponent, { CreateScheduledEventModal } from 'frontend/components/scheduled-event/modal';

@args({
  team: { required: true },
})
export default class ScheduleTab extends Component {
  @service session;
  @service atomic;
  @service modal;
  @service alerts;
  @service store;

  @tracked occurrences = [];
  @tracked from = null;
  @tracked to = null;

  constructor(owner, args) {
    super(owner, args);
    this.setDefaultRange();
  }

  setDefaultRange() {
    const start = DateTime.now().startOf('month');
    const end = start.plus({ months: 2 }).endOf('month');
    this.from = start.toJSDate().toISOString();
    this.to = end.toJSDate().toISOString();
  }

  get occurrencesPromise() {
    return this.loadOccurrencesTask.perform();
  }

  loadOccurrencesTask = task({ drop: true }, async () => {
    const team = this.args.team;
    const adapter = this.store.adapterFor('scheduled-event');
    const icalString = await adapter.occurrences({
      schedulableType: 'Team',
      schedulableId: team.id,
      from: this.from,
      to: this.to,
    });
    const list = parseIcalToOccurrences(icalString);
    this.occurrences = list.map((o) => ({
      ...o,
      startDt: o.startAt ? DateTime.fromISO(o.startAt, { zone: 'utc' }) : null,
    }));
    return this.occurrences;
  });

  get occurrencesWithDt() {
    return this.occurrences;
  }

  createEvent = task({ drop: true }, async () => {
    const team = this.args.team;
    let defaultTimeZone = 'America/Chicago';
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    const org = await activityType.organization;
    if (org?.timeZone) defaultTimeZone = org.timeZone;
    const modalDialog = new CreateScheduledEventModal({
      team,
      atomic: this.atomic,
      defaultTimeZone,
    });
    const result = await this.modal.execute(modalDialog, ScheduledEventModalComponent);
    if (result?.model) {
      this.alerts.success('Event added.');
      await this.loadOccurrencesTask.perform();
    }
  });

  <template>
    <UiCard>
      <div class="schedule-tab__header flex flex-wrap gap-2 items-center justify-between">
        <h2 class="schedule-tab__title text-lg font-semibold">Schedule</h2>
        <UiButton @variant="primary" {{on "click" this.createEvent.perform}}>
          Add event
        </UiButton>
      </div>

      <Await @promise={{this.occurrencesPromise}} @showLatest={{true}}>
        <:resolved as |occList|>
          {{#if occList.length}}
            <ul class="schedule-tab__list">
              {{#each occList as |occ|}}
                {{#unless occ.cancelled}}
                  <li class="schedule-tab__item">
                    <span class="schedule-tab__item-title">{{occ.title}}</span>
                    <FormattedTime @value={{occ.startDt}} @zone={{occ.timeZone}} />
                  </li>
                {{/unless}}
              {{/each}}
            </ul>
          {{else}}
            <p class="text-secondary text-sm text-center py-8">No events in this range. Add an event to get started.</p>
          {{/if}}
        </:resolved>
        <:rejected as |error|>
          <Errors @error={{error}} />
        </:rejected>
      </Await>
    </UiCard>
  </template>
}
