import Component from '@glimmer/component';
import { Errors, action, tracked, on, not, args, eq, fn } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiInput } from 'frontend/components/ui';
import { ModalDialog } from 'frontend/services/modal';
import { task } from 'ember-concurrency';
import preventDefault from 'frontend/helpers/prevent-default';
import { toLocalInputValue, fromLocalInputValue } from 'frontend/utils/datetime';
import { DateTime } from 'luxon';

const RRULE_DAYS = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

function buildRrule(frequency, startAt, weeklyDays) {
  if (!frequency || frequency === 'none') return '';
  if (frequency === 'daily') return 'FREQ=DAILY';
  if (frequency === 'monthly') return 'FREQ=MONTHLY';
  if (frequency === 'weekly') {
    const days = weeklyDays.length ? weeklyDays : [RRULE_DAYS[startAt.weekday === 7 ? 0 : startAt.weekday]];
    return `FREQ=WEEKLY;BYDAY=${days.join(',')}`;
  }
  return '';
}

export class CreateScheduledEventModal extends ModalDialog {
  atomic = null;
  team = null;
  defaultTimeZone = null;

  @tracked title = '';
  @tracked startAt = null;
  @tracked endAt = null;
  @tracked allDay = false;
  @tracked timeZone = '';
  @tracked description = '';
  @tracked repeatFrequency = 'none';
  @tracked weeklyDays = [];
  /** ISO date yyyy-MM-dd; last calendar day (in timeZone) the series may occur */
  @tracked recursUntil = '';
  @tracked exdates = [];
  @tracked exdateToAdd = '';

  title_label = 'New Event';

  constructor({ team, atomic, defaultTimeZone }) {
    super();
    this.atomic = atomic;
    this.team = team;
    this.defaultTimeZone = defaultTimeZone;
    this.timeZone = this.defaultTimeZone;
    const now = DateTime.now().setZone(this.defaultTimeZone);
    const start = now.plus({ days: 1 }).set({ hour: 19, minute: 0, second: 0, millisecond: 0 });
    const end = start.plus({ hours: 1, minutes: 30 });
    this.startAt = start.toUTC();
    this.endAt = end.toUTC();
  }

  get zoneAbbr() {
    return DateTime.now().setZone(this.timeZone).toFormat('ZZZZ');
  }

  get startAtInputValue() {
    return toLocalInputValue(this.startAt, this.timeZone);
  }

  get endAtInputValue() {
    return toLocalInputValue(this.endAt, this.timeZone);
  }

  get rrule() {
    return buildRrule(this.repeatFrequency, this.startAt, this.weeklyDays);
  }

  get exdatesForPayload() {
    return this.exdates.map((d) => (typeof d === 'string' ? d : d.toISODate?.() ?? d));
  }

  saveTask = task({ drop: true }, async () => {
    const payload = {
      title: this.title,
      description: this.description || undefined,
      startAt: this.startAt,
      endAt: this.endAt,
      timeZone: this.timeZone,
      allDay: this.allDay,
      schedulable: this.team,
    };
    const rruleVal = this.rrule;
    if (rruleVal && this.recursUntil) {
      payload.rrule = rruleVal;
      payload.recursUntil = this.recursUntil;
    }
    if (this.exdatesForPayload.length) payload.exdates = this.exdatesForPayload;
    const model = await this.atomic.createModel('scheduled-event', payload);
    this.promise.resolve({ result: 'saved', model });
  });

  get isSaving() {
    return this.saveTask.isRunning;
  }

  get canSave() {
    if (!(this.title.trim().length > 0 && this.startAt && this.endAt && this.endAt > this.startAt)) {
      return false;
    }
    if (this.repeatFrequency !== 'none') {
      return Boolean(this.recursUntil && String(this.recursUntil).trim());
    }
    return true;
  }

  @action
  save() {
    this.saveTask.perform();
  }

  @action
  cancel() {
    this.promise.resolve({ result: 'canceled' });
  }

  @action
  updateTitle(e) {
    this.title = e.target.value;
  }

  @action
  updateDescription(e) {
    this.description = e.target.value;
  }

  @action
  updateTimeZone(e) {
    this.timeZone = e.target.value || this.defaultTimeZone;
  }

  @action
  updateStartAt(e) {
    this.startAt = fromLocalInputValue(e.target.value, this.timeZone);
  }

  @action
  updateEndAt(e) {
    this.endAt = fromLocalInputValue(e.target.value, this.timeZone);
  }

  @action
  updateAllDay(e) {
    this.allDay = e.target.checked;
  }

  @action
  setRepeatFrequency(e) {
    this.repeatFrequency = e.target.value;
    if (this.repeatFrequency !== 'weekly') this.weeklyDays = [];
    if (this.repeatFrequency !== 'none') {
      if (!this.recursUntil && this.startAt) {
        this.recursUntil = this.startAt.setZone(this.timeZone).plus({ months: 2 }).toISODate();
      }
    } else {
      this.recursUntil = '';
    }
  }

  @action
  updateRecursUntil(e) {
    this.recursUntil = e.target?.value ?? '';
  }

  @action
  toggleWeeklyDay(day) {
    const days = [...this.weeklyDays];
    const i = days.indexOf(day);
    if (i >= 0) days.splice(i, 1);
    else days.push(day);
    days.sort((a, b) => RRULE_DAYS.indexOf(a) - RRULE_DAYS.indexOf(b));
    this.weeklyDays = days;
  }

  @action
  addExdate() {
    const str = this.exdateToAdd?.trim();
    if (!str) return;
    const dt = DateTime.fromISO(str);
    if (!dt.isValid) return;
    const iso = dt.toISODate();
    if (this.exdates.includes(iso)) return;
    this.exdates = [...this.exdates, iso];
    this.exdateToAdd = '';
  }

  @action
  removeExdate(index) {
    this.exdates = this.exdates.filter((_, i) => i !== index);
  }

  @action
  updateExdateToAdd(e) {
    this.exdateToAdd = e.target.value;
  }

  @action
  isWeeklyDayChecked(day) {
    return this.weeklyDays.includes(day);
  }

  get showRepeatSection() {
    return true;
  }
}

/**
 * Edit a single occurrence (override) or all future occurrences.
 * Prefills from event + occurrence. For scope 'this_one', no repeat; save = POST new + exdate on original.
 * For scope 'all_future', shows repeat and saves = PATCH or split (split TBD).
 */
export class EditScheduledEventModal extends CreateScheduledEventModal {
  event = null;
  occurrence = null;
  scope = 'this_one'; // 'this_one' | 'all_future'

  constructor({ event, occurrence, team, scope, atomic, defaultTimeZone }) {
    super({ team, atomic, defaultTimeZone });
    this.event = event;
    this.occurrence = occurrence;
    this.scope = scope ?? 'this_one';
    this.title = event.title ?? occurrence.title ?? '';
    this.description = event.description ?? '';
    this.timeZone = event.timeZone ?? this.defaultTimeZone;
    this.allDay = event.allDay ?? false;
    const startAt = occurrence.startAt ?? event.startAt;
    const endAt = occurrence.endAt ?? event.endAt;
    this.startAt = typeof startAt === 'string' ? DateTime.fromISO(startAt, { zone: 'utc' }) : startAt;
    this.endAt = typeof endAt === 'string' ? DateTime.fromISO(endAt, { zone: 'utc' }) : endAt;
    if (this.scope === 'all_future' && event.recursUntil && event.rrule) {
      const ru = event.recursUntil;
      this.recursUntil = typeof ru === 'string' ? ru.split('T')[0] : ru?.toString?.()?.slice(0, 10) ?? '';
      this.repeatFrequency = event.rrule.includes('DAILY') ? 'daily' : event.rrule.includes('MONTHLY') ? 'monthly' : 'weekly';
      const byday = (event.rrule.match(/BYDAY=([^;]+)/i) || [])[1];
      if (byday) this.weeklyDays = byday.split(',').map((d) => d.trim());
      this.exdates = [...(event.exdates || [])];
    }
  }

  title_label = 'Edit event';

  get showRepeatSection() {
    return this.scope === 'all_future';
  }

  saveTask = task({ drop: true }, async () => {
    if (this.scope === 'this_one') {
      const payload = {
        title: this.title,
        description: this.description || undefined,
        startAt: this.startAt,
        endAt: this.endAt,
        timeZone: this.timeZone,
        allDay: this.allDay,
        schedulable: this.team,
      };
      await this.atomic.createModel('scheduled-event', payload);
      const exdates = [...(this.event.exdates || []), this.occurrence.startAt];
      await this.atomic.updateModel(this.event, { exdates });
      this.promise.resolve({ result: 'saved', model: null });
      return;
    }
    // all_future: PATCH the event with form values (simplified; full split logic can be added later)
    const rruleVal = this.rrule;
    const payload = {
      title: this.title,
      description: this.description || undefined,
      startAt: this.startAt,
      endAt: this.endAt,
      timeZone: this.timeZone,
      allDay: this.allDay,
      exdates: this.exdatesForPayload,
    };
    if (rruleVal && this.recursUntil) {
      payload.rrule = rruleVal;
      payload.recursUntil = this.recursUntil;
    }
    await this.atomic.updateModel(this.event, payload);
    this.promise.resolve({ result: 'saved', model: this.event });
  });
}

const WEEKDAY_OPTIONS = [
  { day: 'SU', label: 'Sun' }, { day: 'MO', label: 'Mon' }, { day: 'TU', label: 'Tue' },
  { day: 'WE', label: 'Wed' }, { day: 'TH', label: 'Thu' }, { day: 'FR', label: 'Fri' },
  { day: 'SA', label: 'Sat' },
];

@args({
  modalDialog: { type: ModalDialog, required: true },
})
export default class ScheduledEventModalComponent extends Component {
  weekdayOptions = WEEKDAY_OPTIONS;

  get modalDialog() {
    return this.args.modalDialog;
  }

  <template>
    <UiModal @title={{@modalDialog.title_label}} @onClose={{@modalDialog.cancel}}>
      <Errors @error={{@modalDialog.saveTask.last.error}} />
      <form class="flex flex-col gap-4 scheduled-event-modal" {{on "submit" (preventDefault @modalDialog.save)}}>
        <UiInput
          @label="Title"
          @value={{@modalDialog.title}}
          @placeholder="e.g. Practice, Game vs. Eagles"
          @id="scheduled-event-title"
          {{on "input" @modalDialog.updateTitle}}
        />
        <UiInput
          @label="Description (optional)"
          @value={{@modalDialog.description}}
          @placeholder="Notes or location"
          @id="scheduled-event-description"
          {{on "input" @modalDialog.updateDescription}}
        />
        <div class="datetime-row">
          <UiInput
            @label="Start ({{@modalDialog.zoneAbbr}})"
            @value={{@modalDialog.startAtInputValue}}
            @type="datetime-local"
            @id="scheduled-event-start"
            class="datetime-input"
            {{on "input" @modalDialog.updateStartAt}}
          />
          <UiInput
            @label="End ({{@modalDialog.zoneAbbr}})"
            @value={{@modalDialog.endAtInputValue}}
            @type="datetime-local"
            @id="scheduled-event-end"
            class="datetime-input"
            {{on "input" @modalDialog.updateEndAt}}
          />
        </div>
        <label class="flex items-center gap-2">
          <input type="checkbox" checked={{@modalDialog.allDay}} {{on "change" @modalDialog.updateAllDay}} />
          <span class="text-sm">All day</span>
        </label>

        {{#if @modalDialog.showRepeatSection}}
        <div class="form-group">
          <span class="form-label">Repeat</span>
          <select
            class="form-select"
            value={{@modalDialog.repeatFrequency}}
            {{on "change" @modalDialog.setRepeatFrequency}}
            id="scheduled-event-repeat"
          >
            <option value="none">None</option>
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
        </div>
        {{#if (eq this.modalDialog.repeatFrequency "weekly")}}
          <div class="form-group">
            <span class="form-label">On days</span>
            <div class="weekdays flex flex-wrap gap-2">
              {{#each this.weekdayOptions as |opt|}}
                <label class="flex items-center gap-1.5 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={{this.modalDialog.isWeeklyDayChecked opt.day}}
                    {{on "change" (fn this.modalDialog.toggleWeeklyDay opt.day)}}
                  />
                  <span class="text-sm">{{opt.label}}</span>
                </label>
              {{/each}}
            </div>
          </div>
        {{/if}}

        {{#unless (eq this.modalDialog.repeatFrequency "none")}}
          <div class="form-group">
            <label class="form-label" for="scheduled-event-recurs-until">Repeat until</label>
            <p class="form-hint mb-2">
              Last calendar day an occurrence may fall on ({{@modalDialog.timeZone}}). Start and end times above apply only to the first occurrence.
            </p>
            <input
              id="scheduled-event-recurs-until"
              type="date"
              class="form-input"
              value={{@modalDialog.recursUntil}}
              {{on "input" @modalDialog.updateRecursUntil}}
            />
          </div>
        {{/unless}}

        <div class="form-group">
          <span class="form-label">Exclude dates (optional)</span>
          <p class="form-hint mb-2">Skip these dates in the series.</p>
          <div class="flex flex-wrap gap-2 items-end">
            <div class="form-group flex-1 min-w-[8rem]">
              <label class="form-label visually-hidden" for="scheduled-event-exdate">Add date</label>
              <input
                id="scheduled-event-exdate"
                type="date"
                class="form-input"
                value={{@modalDialog.exdateToAdd}}
                {{on "input" this.modalDialog.updateExdateToAdd}}
              />
            </div>
            <UiButton @variant="secondary" @type="button" {{on "click" @modalDialog.addExdate}}>Add</UiButton>
          </div>
          {{#if @modalDialog.exdates.length}}
            <ul class="exdates mt-2 flex flex-wrap gap-2">
              {{#each @modalDialog.exdates as |iso idx|}}
                <li class="flex items-center gap-1.5 text-sm bg-secondary/10 rounded px-2 py-1">
                  <span>{{iso}}</span>
                  <button type="button" class="text-danger hover:underline" {{on "click" (fn this.modalDialog.removeExdate idx)}} aria-label="Remove">×</button>
                </li>
              {{/each}}
            </ul>
          {{/if}}
        </div>
        {{/if}}

        <div class="flex gap-3 justify-end">
          <UiButton @variant="secondary" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
          <UiButton @type="submit" @loading={{@modalDialog.isSaving}} disabled={{not @modalDialog.canSave}}>
            Save
          </UiButton>
        </div>
      </form>
    </UiModal>
  </template>
}
