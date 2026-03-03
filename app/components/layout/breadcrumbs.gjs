import Component from '@glimmer/component';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { gt } from 'ember-truth-helpers';
import Await from '../await';

export default class BreadcrumbsComponent extends Component {
  @service breadcrumbs;

  <template>
    <Await @promise={{this.breadcrumbs.segments}}>
      <:loading></:loading>
      <:success as |segments|>
        <nav class="breadcrumb">
          {{#each segments as |segment index|}}
            {{#if (gt index 0)}}
              <span class="breadcrumb__separator">/</span>
            {{/if}}
            <LinkTo @route={{segment.name}} @models={{segment.models}}>
              {{segment.title}}
            </LinkTo>
          {{/each}}
        </nav>
      </:success>
    </Await>
  </template>
}
