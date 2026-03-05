import Component from '@glimmer/component';
import { cached, service, on, fn, eq, Errors, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard, UiInput, UiSelect } from 'frontend/components/ui';
import { PageHeader } from 'frontend/components/layout';

const US_TIME_ZONES = [
  { value: 'America/New_York', label: 'Eastern Time (ET)' },
  { value: 'America/Chicago', label: 'Central Time (CT)' },
  { value: 'America/Denver', label: 'Mountain Time (MT)' },
  { value: 'America/Phoenix', label: 'Arizona (no DST)' },
  { value: 'America/Los_Angeles', label: 'Pacific Time (PT)' },
  { value: 'America/Anchorage', label: 'Alaska Time (AKT)' },
  { value: 'Pacific/Honolulu', label: 'Hawaii Time (HT)' },
];

@args({
  org: { required: true },
})
export default class SettingsPage extends Component {
  @service atomic;
  @service alerts;
  @service session;

  @cached
  get trackedModel() {
    return this.atomic.trackedModel(this.args.org);
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.args.org, this.trackedModel);
    this.session.setOrganization(this.args.org);
    this.alerts.success('Settings saved.');
  });

  updateField = (field, event) => {
    this.trackedModel[field] = event.target.value;
  };

  handleSubmit = (event) => {
    event.preventDefault();
    this.saveTask.perform();
  };

  <template>
    <PageHeader>
      <:title>Settings</:title>
      <:description>Organization settings and preferences</:description>
    </PageHeader>

    <div class="form-page">
      <UiCard>
        <Errors @error={{this.saveTask.last.error}} />
        <form class="flex flex-col gap-4" {{on "submit" this.handleSubmit}}>
          <UiInput
            @label="Organization Name"
            @value={{this.trackedModel.name}}
            @placeholder="e.g. St. Mary's School"
            @id="org-name"
            {{on "input" (fn this.updateField "name")}}
          />

          <UiInput
            @label="URL Slug"
            @value={{this.trackedModel.slug}}
            @placeholder="e.g. st-marys"
            @hint="Lowercase letters, numbers, and hyphens only. This appears in your organization's URL."
            @id="org-slug"
            {{on "input" (fn this.updateField "slug")}}
          />

          <div class="form-group">
            <label class="form-label" for="org-timezone">Time Zone</label>
            <select
              id="org-timezone"
              class="form-select"
              {{on "change" (fn this.updateField "timeZone")}}
            >
              {{#each US_TIME_ZONES as |tz|}}
                <option value={{tz.value}} selected={{if (eq this.trackedModel.timeZone tz.value) true}}>
                  {{tz.label}}
                </option>
              {{/each}}
            </select>
          </div>

          <div class="flex gap-3 justify-end">
            <UiButton @type="submit" @loading={{this.saveTask.isRunning}} disabled={{this.saveTask.isRunning}}>
              Save Changes
            </UiButton>
          </div>
        </form>
      </UiCard>
    </div>
  </template>
}
