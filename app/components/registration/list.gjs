import Component from '@glimmer/component';
import { on, fn, Await, LoadingIndicator, args, service, eq } from 'frontend/utils/stdlib';
import { UiCard, UiButton } from 'frontend/components/ui';
import InfiniteScroll from 'frontend/components/infinite-scroll';
import Paginator from 'frontend/utils/paginator';
import { task } from 'ember-concurrency';

const STATUS_OPTIONS = ['pending', 'confirmed', 'waitlisted', 'canceled', 'not_selected'];

function statusLabel(status) {
  if (status === 'not_selected') return 'Not Selected';
  return status ? status.charAt(0).toUpperCase() + status.slice(1) : '';
}

@args({
  paginator: { type: Paginator, required: true },
  onSearch: { type: 'function', required: true },
  onCreate: { type: 'function' },
})
export default class RegistrationListComponent extends Component {
  @service atomic;
  @service alerts;
  @service modal;

  updateStatus = task(async (registration, event) => {
    const newStatus = event.target.value;
    if (newStatus === registration.status) return;
    await this.atomic.patchModel(registration, { status: newStatus });
    this.alerts.success('Status updated.');
  });

  deleteRegistration = task(async (registration) => {
    const user = await registration.user;
    const userName = user?.fullName || 'this participant';
    const confirmed = await this.modal.confirm(`Remove registration for ${userName}?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(registration);
    this.alerts.success('Registration removed.');
    await this.args.paginator.reload();
  });


  <template>
    <Await @promise={{@paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Participant</th>
              <th>Status</th>
              <th class="hide-mobile">Registered By</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{@paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |registration|>
                <tr>
                  <td class="font-medium">
                    <Await @promise={{registration.user}} as |user|>
                      {{user.fullName}}
                    </Await>
                  </td>
                  <td>
                    <select
                      aria-label="Registration status"
                      class="form-select form-select--inline"
                      {{on "change" (fn this.updateStatus.perform registration)}}
                    >
                      {{#each STATUS_OPTIONS as |status|}}
                        <option value={{status}} selected={{if (eq registration.status status) true}}>
                          {{statusLabel status}}
                        </option>
                      {{/each}}
                    </select>
                  </td>
                  <td class="text-secondary hide-mobile">
                    <Await @promise={{registration.registeredBy}} as |registeredBy|>
                      {{registeredBy.fullName}}
                    </Await>
                  </td>
                  <td class="data-table__actions">
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.deleteRegistration.perform registration)}}>
                      Remove
                    </UiButton>
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
                      <p class="empty-state__message">No registrations yet</p>
                      <p class="empty-state__hint">Register participants for this league to build your roster.</p>
                      {{#if @onCreate}}
                        <UiButton class="mt-4" {{on "click" @onCreate}}>Register Participant</UiButton>
                      {{/if}}
                    </div>
                  </td>
                </tr>
              </:empty>
            </InfiniteScroll>
          </tbody>
        </table>
      </UiCard>
    </Await>
  </template>
}
