import Component from '@glimmer/component';
import { service, LinkTo, gt, Await } from 'frontend/utils/stdlib';
import viewTransitionName from 'frontend/modifiers/view-transition-name';

export default class BreadcrumbsComponent extends Component {
  @service breadcrumbs;

  <template>
    <Await @promise={{this.breadcrumbs.segments}}>
      <:loading></:loading>
      <:success as |segments|>
        {{#if segments}}
          <nav class="breadcrumb" {{viewTransitionName 'breadcrumbs'}}>
            {{#each segments as |segment index|}}
              {{#if (gt index 0)}}
                <span class="breadcrumb-separator">/</span>
              {{/if}}
              <LinkTo @route={{segment.name}} @models={{segment.models}}>
                {{segment.title}}
              </LinkTo>
            {{/each}}
          </nav>
        {{/if}}
      </:success>
    </Await>
  </template>
}
