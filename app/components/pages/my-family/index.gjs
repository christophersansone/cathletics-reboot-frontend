import Component from '@glimmer/component';
import { tracked, action, service, on, LinkTo } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard, UiInput } from 'frontend/components/ui';
import preventDefault from 'frontend/helpers/prevent-default';

export default class MyFamilyIndexPage extends Component {
  @service atomic;
  @service session;
  @service alerts;
  @service router;

  @tracked familyName = '';
  @tracked isCreating = false;

  @action updateFamilyName(event) {
    this.familyName = event.target.value;
  }

  @action showCreateForm() {
    this.isCreating = true;
  }

  createFamilyTask = task({ drop: true }, async () => {
    const name = this.familyName || `The ${this.session.currentUser.lastName} Family`;
    const family = await this.atomic.createModel('family', { name });
    this.alerts.success('Family created!');
    this.router.transitionTo('my-family.family', family.id);
  });

  <template>
    <div class="member-page">
        {{#if @families.length}}
          <UiCard @title="My Families">
            <ul class="family-list">
              {{#each @families as |family|}}
                <li class="family-list__item">
                  <LinkTo @route="my-family.family" @model={{family.id}} class="font-medium text-link">
                    {{family.name}}
                  </LinkTo>
                </li>
              {{/each}}
            </ul>

            {{#if this.isCreating}}
              <form class="flex flex-col gap-4 mt-4" {{on "submit" (preventDefault this.createFamilyTask.perform)}}>
                <UiInput
                  @label="Family Name"
                  @value={{this.familyName}}
                  @placeholder="e.g. The Smith Family"
                  @hint="Leave blank to auto-generate"
                  @id="family-name"
                  {{on "input" this.updateFamilyName}}
                />
                <UiButton @type="submit" @full={{true}} @loading={{this.createFamilyTask.isRunning}} disabled={{this.createFamilyTask.isRunning}}>
                  Create Family
                </UiButton>
              </form>
            {{else}}
              <div class="mt-4">
                <UiButton @variant="secondary" @size="sm" {{on "click" this.showCreateForm}}>
                  Create Another Family
                </UiButton>
              </div>
            {{/if}}
          </UiCard>
        {{else}}
          <UiCard>
            <div class="flex flex-col gap-4 text-center">
              <h2 class="text-lg font-semibold">Create Your Family</h2>
              <p class="text-secondary text-sm">Set up your family to register children for activities.</p>

              <form class="flex flex-col gap-4" {{on "submit" (preventDefault this.createFamilyTask.perform)}}>
                <UiInput
                  @label="Family Name"
                  @value={{this.familyName}}
                  @placeholder="e.g. The Smith Family"
                  @hint="Leave blank to auto-generate"
                  @id="family-name"
                  {{on "input" this.updateFamilyName}}
                />
                <UiButton @type="submit" @full={{true}} @loading={{this.createFamilyTask.isRunning}} disabled={{this.createFamilyTask.isRunning}}>
                  Create Family
                </UiButton>
              </form>
            </div>
          </UiCard>
        {{/if}}
    </div>
  </template>
}
