import Component from '@glimmer/component';
import { on, fn, array, LinkTo, Await, LoadingIndicator, args } from 'frontend/utils/stdlib';
import { UiCard, UiButton } from 'frontend/components/ui';
import InfiniteScroll from 'frontend/components/infinite-scroll';
import Organization from 'frontend/models/organization';
import Paginator from 'frontend/utils/paginator';

@args({
  org: { type: Organization, required: true },
  paginator: { type: Paginator, required: true },
  onEdit: { type: 'function', required: true },
  onDelete: { type: 'function', required: true },
  onCreate: { type: 'function', required: true },
})
export default class TeamListComponent extends Component {
  <template>
    <Await @promise={{@paginator.firstPage}} @showLatest={{true}}>
      <UiCard @padding={{false}}>
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th class="data-table__actions-col"></th>
            </tr>
          </thead>
          <tbody>
            <InfiniteScroll @paginator={{@paginator}} @occlude={{true}} @scrollElement=".app-content">
              <:item as |team|>
                <tr>
                  <td class="font-medium">
                    <LinkTo @route="orgs.org.teams.team" @models={{array @org.slug team.id}} class="text-link">
                      {{team.name}}
                    </LinkTo>
                  </td>
                  <td class="data-table__actions">
                    <UiButton @variant="ghost" @size="sm" {{on "click" (fn @onEdit team)}}>
                      Edit
                    </UiButton>
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn @onDelete team)}}>
                      Delete
                    </UiButton>
                  </td>
                </tr>
              </:item>

              <:sentinel as |sentinelModifier|>
                <tr {{sentinelModifier}}>
                  <td colspan="2" class="infinite-scroll-page-sentinel"></td>
                </tr>
              </:sentinel>

              <:loading as |loadingModifier|>
                <tr {{loadingModifier}}>
                  <td colspan="2"><LoadingIndicator /></td>
                </tr>
              </:loading>

              <:empty>
                <tr>
                  <td colspan="2">
                    <div class="empty-state">
                      <p class="empty-state__message">No teams yet</p>
                      <p class="empty-state__hint">Create teams to organize players into groups within this league.</p>
                      <UiButton class="mt-4" {{on "click" @onCreate}}>Create Team</UiButton>
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
