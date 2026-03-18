import Component from '@glimmer/component';
import { Errors, action, tracked, on, not, args } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiInput } from 'frontend/components/ui';
import { ModalDialog } from 'frontend/services/modal';
import { task } from 'ember-concurrency';
import preventDefault from 'frontend/helpers/prevent-default';
import { toLocalInputValue, fromLocalInputValue } from 'frontend/utils/datetime';
import { DateTime } from 'luxon';

export class CreateScheduledEventModal extends ModalDialog {
  atomic = null;
  team = null;
  defaultTimeZone = 'America/Chicago';

  @tracked title = '';
  @tracked startAt = null;
  @tracked endAt = null;
  @tracked allDay = false;
  @tracked timeZone = '';
  @tracked description = '';

  title_label = 'New Event';

  constructor({ team, atomic, defaultTimeZone }) {
    super();
    this.atomic = atomic;
    this.team = team;
    this.defaultTimeZone = defaultTimeZone || 'America/Chicago';
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

  saveTask = task({ drop: true }, async () => {
    const model = await this.atomic.createModel('scheduled-event', {
      title: this.title,
      description: this.description || undefined,
      startAt: this.startAt,
      endAt: this.endAt,
      timeZone: this.timeZone,
      allDay: this.allDay,
      schedulable: this.team,
    });
    this.promise.resolve({ result: 'saved', model });
  });

  get isSaving() {
    return this.saveTask.isRunning;
  }

  get canSave() {
    return this.title.trim().length > 0 && this.startAt && this.endAt && this.endAt > this.startAt;
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
}

@args({
  modalDialog: { type: ModalDialog, required: true },
})
export default class ScheduledEventModalComponent extends Component {
  <template>
    <UiModal @title={{@modalDialog.title_label}} @onClose={{@modalDialog.cancel}}>
      <Errors @error={{@modalDialog.saveTask.last.error}} />
      <form class="flex flex-col gap-4" {{on "submit" (preventDefault @modalDialog.save)}}>
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
        <div class="form-row">
          <UiInput
            @label="Start ({{@modalDialog.zoneAbbr}})"
            @value={{@modalDialog.startAtInputValue}}
            @type="datetime-local"
            @id="scheduled-event-start"
            {{on "input" @modalDialog.updateStartAt}}
          />
          <UiInput
            @label="End ({{@modalDialog.zoneAbbr}})"
            @value={{@modalDialog.endAtInputValue}}
            @type="datetime-local"
            @id="scheduled-event-end"
            {{on "input" @modalDialog.updateEndAt}}
          />
        </div>
        <label class="flex items-center gap-2">
          <input type="checkbox" checked={{@modalDialog.allDay}} {{on "change" @modalDialog.updateAllDay}} />
          <span class="text-sm">All day</span>
        </label>
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
