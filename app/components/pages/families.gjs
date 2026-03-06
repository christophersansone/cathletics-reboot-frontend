import Component from '@glimmer/component';
import { tracked, cached, service, on, gt, Await, LoadingIndicator, args } from 'frontend/utils/stdlib';
import { task, timeout } from 'ember-concurrency';
import { concat } from '@ember/helper';
import { UiCard, UiInput } from 'frontend/components/ui';
import InfiniteScroll from '../infinite-scroll';
import { PageHeader } from 'frontend/components/layout';

function childCount(memberships) {
  return memberships.filter((m) => m.role === 'child').length;
}

function parentsOf(memberships) {
  return memberships.filter((m) => m.role === 'parent' || m.role === 'guardian');
}

@args({
  org: { required: true },
})
export default class FamiliesPage extends Component {
  @service pagination;

  @tracked searchQuery = '';

  @cached
  get paginator() {
    const params = {};
    if (this.searchQuery) params.q = this.searchQuery;
    return this.pagination.query('family', params);
  }

  searchTask = task({ restartable: true }, async (event) => {
    await timeout(300);
    this.searchQuery = event.target.value;
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
                  <td class="text-secondary hide-mobile">
                    <Await @promise={{family.familyMemberships}} as |memberships|>
                      {{#each (parentsOf memberships) as |member index|}}
                        <Await @promise={{member.user}} as |user|>
                          {{concat (if (gt index 0) ', ') user.fullName}}
                        </Await>
                      {{/each}}
                    </Await>
                  </td>
                  <td>
                    <Await @promise={{family.familyMemberships}} as |memberships|>
                      {{childCount memberships}}
                    </Await>
                  </td>
                  <td class="hide-mobile">
                    <Await @promise={{family.familyMemberships}} as |memberships|>
                      {{memberships.length}}
                    </Await>
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
