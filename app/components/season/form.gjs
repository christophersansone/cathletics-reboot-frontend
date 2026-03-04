import Component from '@glimmer/component';
import { action, on, fn } from 'frontend/utils/stdlib';
import { UiInput, UiButton } from 'frontend/components/ui';
import autoFocus from 'frontend/modifiers/auto-focus';
import { toLocalInputValue, fromLocalInputValue } from 'frontend/utils/datetime';
import { DateTime } from 'luxon';

export default class SeasonForm extends Component {
  get zone() {
    return this.args.timeZone || 'UTC';
  }

  get zoneAbbr() {
    return DateTime.now().setZone(this.zone).toFormat('ZZZZ');
  }

  get regStartValue() {
    return toLocalInputValue(this.args.season.registrationStartAt, this.zone);
  }

  get regEndValue() {
    return toLocalInputValue(this.args.season.registrationEndAt, this.zone);
  }

  @action
  updateField(field, event) {
    this.args.season[field] = event.target.value;
  }

  @action
  updateDateTimeField(field, event) {
    this.args.season[field] = fromLocalInputValue(event.target.value, this.zone);
  }

  @action
  handleSubmit(event) {
    event.preventDefault();
    this.args.onSave();
  }

  <template>
    <form class="flex flex-col gap-4" {{on "submit" this.handleSubmit}}>
      <UiInput
        @label="Name"
        @value={{@season.name}}
        @placeholder="e.g. Fall 2026, Spring 2027"
        @id="season-name"
        {{on "input" (fn this.updateField "name")}}
        {{autoFocus}}
      />

      <div class="form-row">
        <UiInput
          @label="Start Date"
          @value={{@season.startDate}}
          @type="date"
          @id="season-start-date"
          {{on "input" (fn this.updateField "startDate")}}
        />
        <UiInput
          @label="End Date"
          @value={{@season.endDate}}
          @type="date"
          @id="season-end-date"
          {{on "input" (fn this.updateField "endDate")}}
        />
      </div>

      <div class="form-row">
        <UiInput
          @label="Registration Opens ({{this.zoneAbbr}})"
          @value={{this.regStartValue}}
          @type="datetime-local"
          @id="season-reg-start"
          @hint="When parents can begin registering"
          {{on "input" (fn this.updateDateTimeField "registrationStartAt")}}
        />
        <UiInput
          @label="Registration Closes ({{this.zoneAbbr}})"
          @value={{this.regEndValue}}
          @type="datetime-local"
          @id="season-reg-end"
          {{on "input" (fn this.updateDateTimeField "registrationEndAt")}}
        />
      </div>

      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @onCancel}}>
          Cancel
        </UiButton>
        <UiButton @type="submit" @loading={{@isSaving}} disabled={{@isSaving}}>
          {{if @isNew "Create Season" "Save Changes"}}
        </UiButton>
      </div>
    </form>
  </template>
}
