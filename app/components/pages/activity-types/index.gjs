import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { task } from 'ember-concurrency';
import UiButton from 'frontend/components/ui/button';
import UiCard from 'frontend/components/ui/card';
import UiModal from 'frontend/components/ui/modal';
import ActivityTypeForm from 'frontend/components/activity-type-form';

export default class ActivityTypesIndexPage extends Component {
  @service store;

  @tracked editingActivityType = null;

  get isFormOpen() {
    return this.editingActivityType !== null;
  }

  get formTitle() {
    return this.editingActivityType?.isNew ? 'New Activity Type' : 'Edit Activity Type';
  }

  @action
  openCreate() {
    this.editingActivityType = this.store.createRecord('activity-type', {
      organization: this.args.org,
    });
  }

  @action
  openEdit(activityType) {
    this.editingActivityType = activityType;
  }

  @action
  closeForm() {
    if (this.editingActivityType?.isNew) {
      this.editingActivityType.rollbackAttributes();
    }
    this.editingActivityType = null;
  }

  saveTask = task(async () => {
    await this.editingActivityType.save();
    this.editingActivityType = null;
  });

  deleteTask = task(async (activityType) => {
    if (!window.confirm(`Delete "${activityType.name}"? This cannot be undone.`)) return;
    await activityType.destroyRecord();
  });

  <template>
    <div class="page-header flex items-center justify-between">
      <div>
        <h1 class="page-header__title">Activities</h1>
        <p class="page-header__description">Manage activity types, seasons, and leagues</p>
      </div>
      <UiButton {{on "click" this.openCreate}}>
        New Activity Type
      </UiButton>
    </div>

    {{#if @activityTypes.length}}
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            {{#each @activityTypes as |at|}}
              <tr>
                <td class="font-medium">{{at.name}}</td>
                <td class="text-secondary">{{at.description}}</td>
                <td class="data-table__actions">
                  <UiButton @variant="ghost" @size="sm" {{on "click" (fn this.openEdit at)}}>
                    Edit
                  </UiButton>
                  <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.deleteTask.perform at)}}>
                    Delete
                  </UiButton>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </UiCard>
    {{else}}
      <UiCard>
        <div class="empty-state">
          <p class="empty-state__message">No activity types yet</p>
          <p class="empty-state__hint">Create your first activity type to get started with seasons and leagues.</p>
          <UiButton class="mt-4" {{on "click" this.openCreate}}>
            Create Activity Type
          </UiButton>
        </div>
      </UiCard>
    {{/if}}

    {{#if this.isFormOpen}}
      <UiModal @title={{this.formTitle}} @onClose={{this.closeForm}}>
        <ActivityTypeForm
          @activityType={{this.editingActivityType}}
          @onSave={{this.saveTask.perform}}
          @onCancel={{this.closeForm}}
          @isSaving={{this.saveTask.isRunning}}
        />
      </UiModal>
    {{/if}}
  </template>
}
