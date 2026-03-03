import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { eq } from 'ember-truth-helpers';
import UiInput from 'frontend/components/ui/input';
import UiButton from 'frontend/components/ui/button';
import autoFocus from 'frontend/modifiers/auto-focus';

export default class LeagueForm extends Component {
  @action
  updateField(field, event) {
    this.args.league[field] = event.target.value || null;
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
        @value={{@league.name}}
        @placeholder="Optional — auto-generated from constraints"
        @hint="Leave blank to auto-generate from gender and grade/age range"
        @id="league-name"
        {{on "input" (fn this.updateField "name")}}
        {{autoFocus}}
      />

      <div class="form-group">
        <label class="form-label" for="league-gender">Gender</label>
        <select
          id="league-gender"
          class="form-select"
          {{on "change" (fn this.updateField "gender")}}
        >
          <option value="" selected={{eq @league.gender null}}>Any</option>
          <option value="male" selected={{eq @league.gender "male"}}>Male</option>
          <option value="female" selected={{eq @league.gender "female"}}>Female</option>
        </select>
      </div>

      <div class="form-row">
        <UiInput
          @label="Min Grade"
          @value={{@league.minGrade}}
          @type="number"
          @placeholder="e.g. 5"
          @hint="-1 = Pre-K, 0 = K"
          @id="league-min-grade"
          {{on "input" (fn this.updateField "minGrade")}}
        />
        <UiInput
          @label="Max Grade"
          @value={{@league.maxGrade}}
          @type="number"
          @placeholder="e.g. 6"
          @id="league-max-grade"
          {{on "input" (fn this.updateField "maxGrade")}}
        />
      </div>

      <div class="form-row">
        <UiInput
          @label="Min Age"
          @value={{@league.minAge}}
          @type="number"
          @placeholder="Optional"
          @id="league-min-age"
          {{on "input" (fn this.updateField "minAge")}}
        />
        <UiInput
          @label="Max Age"
          @value={{@league.maxAge}}
          @type="number"
          @placeholder="Optional"
          @id="league-max-age"
          {{on "input" (fn this.updateField "maxAge")}}
        />
      </div>

      <UiInput
        @label="Age Cutoff Date"
        @value={{@league.ageCutoffDate}}
        @type="date"
        @hint="Child must be within age range as of this date"
        @id="league-age-cutoff"
        {{on "input" (fn this.updateField "ageCutoffDate")}}
      />

      <UiInput
        @label="Capacity"
        @value={{@league.capacity}}
        @type="number"
        @placeholder="Unlimited"
        @hint="Maximum number of registrations (leave blank for unlimited)"
        @id="league-capacity"
        {{on "input" (fn this.updateField "capacity")}}
      />

      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @onCancel}}>
          Cancel
        </UiButton>
        <UiButton @type="submit" @loading={{@isSaving}} disabled={{@isSaving}}>
          {{if @isNew "Create League" "Save Changes"}}
        </UiButton>
      </div>
    </form>
  </template>
}
