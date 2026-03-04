import Component from '@glimmer/component';
import { action, on, fn } from 'frontend/utils/stdlib';
import { UiInput, UiButton } from 'frontend/components/ui';
import autoFocus from 'frontend/modifiers/auto-focus';

export default class ActivityTypeForm extends Component {
  @action
  updateField(field, event) {
    this.args.activityType[field] = event.target.value;
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
        @value={{@activityType.name}}
        @placeholder="e.g. Football, Choir, Book Club"
        @id="activity-type-name"
        {{on "input" (fn this.updateField "name")}}
        {{autoFocus}}
      />

      <UiInput
        @label="Description"
        @value={{@activityType.description}}
        @placeholder="Optional description"
        @id="activity-type-description"
        {{on "input" (fn this.updateField "description")}}
      />

      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @onCancel}}>
          Cancel
        </UiButton>
        <UiButton @type="submit" @loading={{@isSaving}} disabled={{@isSaving}}>
          {{if @activityType.isNew "Create" "Save"}}
        </UiButton>
      </div>
    </form>
  </template>
}
