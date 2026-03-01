import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { task } from 'ember-concurrency';
import UiButton from '../../ui/button';
import UiCard from '../../ui/card';
import UiModal from '../../ui/modal';
import ActivityTypeForm from '../../activity-type-form';
import Await from '../../await';
import Errors from '../../errors';
import args from 'frontend/decorators/args';
import DeferredPromise from 'frontend/utils/deferred-promise';
import Organization from 'frontend/models/organization';

class Modal {
  atomic = null;
  promise = null;

  title = null;

  constructor({ atomic }) {
    this.atomic = atomic;
    this.promise = new DeferredPromise();
  }

  saveTask = task({ drop: true }, async () => {
    throw new Error('Not implemented');
  });

  get isSaving() {
    return this.saveTask.isRunning;
  }

  @action
  save() {
    this.saveTask.perform();
  }

  @action
  cancel() {
    this.promise.resolve({ result: 'canceled' });
  }
}

class EditModal extends Modal {
  model = null;
  trackedModel = null;

  title = 'Edit Activity Type';

  constructor({ model, atomic }) {
    super({ atomic });
    this.model = model;
    this.trackedModel = atomic.trackedModel(model);
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.model, this.trackedModel);
    this.promise.resolve({ result: 'saved', model: this.model });
  });
}

class CreateModal extends Modal {
  trackedModel = null;

  title = 'New Activity Type';

  constructor({ organization, atomic }) {
    super({ atomic });
    this.trackedModel = atomic.newTrackedModel('activity-type', { organization });
  }

  saveTask = task({ drop: true }, async () => {
   const model = await this.atomic.createModel('activity-type', this.trackedModel);
    this.promise.resolve({ result: 'saved', model });
  });
}

@args({
  org: { type: Organization, required: true },
})
export default class ActivityTypesIndexPage extends Component {
  @service store;
  @service atomic;
  @service pagination;

  @tracked modal = null;

  @cached
  get paginator() {
    return this.pagination.query('activity-type', {});
  }

  editActivityType = task({ drop: true }, async (activityType) => {
    try {
      this.modal = new EditModal({ model: activityType, atomic: this.atomic });
      return await this.modal.promise;
    } finally {
      this.modal = null;
    }
  });

  createActivityType = task({ drop: true }, async () => {
    try {
      this.modal = new CreateModal({ organization: this.args.org, atomic: this.atomic });
      const result = await this.modal.promise;
      if (result.model) {
        await this.paginator.reload();
      }
      return result;
    } finally {
      this.modal = null;
    }
  });

  deleteActivityType = task(async (activityType) => {
    if (!window.confirm(`Delete "${activityType.name}"? This cannot be undone.`)) return;
    await this.atomic.destroyModel(activityType);
  });

  <template>
    <div class="page-header flex items-center justify-between">
      <div>
        <h1 class="page-header__title">Activities</h1>
        <p class="page-header__description">Manage activity types, seasons, and leagues</p>
      </div>
      <UiButton {{on "click" this.createActivityType.perform}}>
        New Activity Type
      </UiButton>
    </div>

    <Await @promise={{this.paginator.firstPage}} showLatest={{true}}>
      {{#if this.paginator.displayItems.length}}
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
              {{#each this.paginator.displayItems as |at|}}
                <tr>
                  <td class="font-medium">{{at.name}}</td>
                  <td class="text-secondary">{{at.description}}</td>
                  <td class="data-table__actions">
                    <UiButton @variant="ghost" @size="sm" {{on "click" (fn this.editActivityType.perform at)}}>
                      Edit
                    </UiButton>
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.deleteActivityType.perform at)}}>
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
            <UiButton class="mt-4" {{on "click" this.createActivityType.perform}}>
              Create Activity Type
            </UiButton>
          </div>
        </UiCard>
      {{/if}}
    </Await>

    {{#if this.modal}}
      <UiModal @title={{this.modal.title}} @onClose={{this.modal.cancel}}>
        <Errors @error={{this.modal.saveTask.last.error}} class="errors" />
        <ActivityTypeForm
          @activityType={{this.modal.trackedModel}}
          @onSave={{this.modal.save}}
          @onCancel={{this.modal.cancel}}
          @isSaving={{this.modal.isSaving}}
        />
      </UiModal>
    {{/if}}
  </template>
}
