import Component from '@glimmer/component';
import { tracked, cached, service, on, fn, eq, Await, LoadingIndicator, args } from 'frontend/utils/stdlib';
import { task, timeout } from 'ember-concurrency';
import { UiCard, UiInput } from 'frontend/components/ui';
import InfiniteScroll from '../infinite-scroll';
import { PageHeader } from 'frontend/components/layout';

function parentNames(family) {
  const memberships = family.familyMemberships?.slice?.() || [];
  return memberships
    .filter((m) => m.role === 'parent' || m.role === 'guardian')
    .map((m) => m.user?.content?.fullName ?? m.user?.fullName ?? '')
    .filter(Boolean)
    .join(', ');
}

function childCount(family) {
  const memberships = family.familyMemberships?.slice?.() || [];
  return memberships.filter((m) => m.role === 'child').length;
}

function memberCount(family) {
  return family.familyMemberships?.length ?? 0;
}

@args({
  org: { required: true },
})
export default class FamiliesPage extends Component {
  @service pagination;

  @tracked searchQuery = '';
  @tracked _paginatorKey = 0;

  @cached
  get paginator() {
    this._paginatorKey;
    const params = {};
    if (this.searchQuery) params.q = this.searchQuery;
    return this.pagination.query('family', params);
  }

  searchTask = task({ restartable: true }, async (event) => {
    await timeout(300);
    this.searchQuery = event.target.value;
    this._paginatorKey++;
  });

  <template>
    <PageHeader>
      <:title>Families</:title>
      <:description>View and manage family units</:description>
    </PageHeader>

    <div class="mb-4">
      <UiInput
        @placeholder="Search by family name..."
        @id="family-search"
        {{on "input" this.searchTask.perform}}
      />
    </div>

    <Await @promise={{this.paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Family Name</th>
              <th class="hide-mobile">Parents / Guardians</th>
              <th>Children</th>
              <th class="hide-mobile">Total Members</th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{this.paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |family|>
                <tr>
                  <td class="font-medium">{{family.name}}</td>
                  <td class="text-secondary hide-mobile">{{parentNames family}}</td>
                  <td>{{childCount family}}</td>
                  <td class="hide-mobile">{{memberCount family}}</td>
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
                      <p class="empty-state__message">No families found</p>
                      <p class="empty-state__hint">Families are created when members register and set up their households.</p>
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
