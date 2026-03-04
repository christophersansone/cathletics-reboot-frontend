import Component from '@glimmer/component';
import { tracked, cached, action, service, on, array, LinkTo, Await, Errors, LoadingIndicator, args, DeferredPromise } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard, UiModal, UiBadge } from 'frontend/components/ui';
import ActivityTypeForm from '../../activity-type/form';
import InfiniteScroll from '../../infinite-scroll';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';

class EditModal {
  trackedModel = null;
  promise = null;
  atomic = null;
  model = null;

  constructor({ model, atomic }) {
    this.model = model;
    this.atomic = atomic;
    this.trackedModel = atomic.trackedModel(model);
    this.promise = new DeferredPromise();
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.model, this.trackedModel);
    this.promise.resolve({ result: 'saved' });
  });

  get isSaving() { return this.saveTask.isRunning; }

  @action save() { this.saveTask.perform(); }
  @action cancel() { this.promise.resolve({ result: 'canceled' }); }
}

@args({
  activityType: { required: true },
  org: { required: true },
})
export default class ActivityTypeShowPage extends Component {
  @service atomic;
  @service pagination;
  @service router;
  @service alerts;
  @service('modal') modalService;

  @tracked modal = null;

  @cached
  get paginator() {
    return this.pagination.query('season', { activity_type_id: this.args.activityType.id });
  }

  editActivityType = task({ drop: true }, async () => {
    try {
      this.modal = new EditModal({ model: this.args.activityType, atomic: this.atomic });
      const result = await this.modal.promise;
      if (result.result === 'saved') {
        this.alerts.success('Activity type updated.');
      }
    } finally {
      this.modal = null;
    }
  });

  deleteActivityType = task(async () => {
    const confirmed = await this.modalService.confirm(`Delete "${this.args.activityType.name}"? This will also remove all seasons and leagues.`);
    if (!confirmed) return;
    await this.atomic.destroyModel(this.args.activityType);
    this.alerts.success('Activity type deleted.');
    this.router.transitionTo('orgs.org.activity-types', this.args.org.slug);
  });

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>{{@activityType.name}}</:title>
      <:description>{{@activityType.description}}</:description>
      <:actions>
        <UiButton @variant="ghost" @size="sm" {{on "click" this.editActivityType.perform}}>
          Edit
        </UiButton>
        <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" this.deleteActivityType.perform}}>
          Delete
        </UiButton>
      </:actions>
    </DetailHeader>

    <div class="section-header">
      <h2 class="section-header__title">Seasons</h2>
      <LinkTo @route="orgs.org.activity-types.activity-type.new-season" @models={{array @org.slug @activityType.id}}>
        <UiButton @size="sm">New Season</UiButton>
      </LinkTo>
    </div>

    <Await @promise={{this.paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th class="hide-mobile">Dates</th>
              <th>Registration</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{this.paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |season|>
                <tr>
                  <td class="font-medium">
                    <LinkTo @route="orgs.org.seasons.season" @models={{array @org.slug season.id}} class="text-link">
                      {{season.name}}
                    </LinkTo>
                  </td>
                  <td class="text-secondary hide-mobile">
                    {{#if season.startDate}}
                      {{season.startDate}} — {{season.endDate}}
                    {{else}}
                      —
                    {{/if}}
                  </td>
                  <td>
                    {{#if season.registrationOpen}}
                      <UiBadge @variant="success">Open</UiBadge>
                    {{else}}
                      <UiBadge @variant="default">Closed</UiBadge>
                    {{/if}}
                  </td>
                  <td class="data-table__actions">
                    <LinkTo @route="orgs.org.seasons.season" @models={{array @org.slug season.id}}>
                      <UiButton @variant="ghost" @size="sm">View</UiButton>
                    </LinkTo>
                  </td>
                </tr>
              </:item>

              <:sentinel as |sentinelModifier|>
                <tr {{sentinelModifier}}>
                  <td colspan="4" class="infinite-scroll-page-sentinel"></td>
                </tr>
              </:sentinel>

              <:loading as |loadingModifier|>
                <tr {{loadingModifier}}>
                  <td colspan="4"><LoadingIndicator /></td>
                </tr>
              </:loading>

              <:empty>
                <tr>
                  <td colspan="4">
                    <div class="empty-state">
                      <p class="empty-state__message">No seasons yet</p>
                      <p class="empty-state__hint">Create the first season to start organizing leagues and registrations.</p>
                      <LinkTo @route="orgs.org.activity-types.activity-type.new-season" @models={{array @org.slug @activityType.id}}>
                        <UiButton class="mt-4">Create Season</UiButton>
                      </LinkTo>
                    </div>
                  </td>
                </tr>
              </:empty>
            </InfiniteScroll>
          </tbody>
        </table>
      </UiCard>
    </Await>

    {{#if this.modal}}
      <UiModal @title="Edit Activity Type" @onClose={{this.modal.cancel}}>
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
