import Component from '@glimmer/component';
import { LinkTo } from '@ember/routing';
import UiCard from 'frontend/components/ui/card';
import UiBadge from 'frontend/components/ui/badge';
import { eq } from 'ember-truth-helpers';

export default class OrgSelectorPage extends Component {
  <template>
    <div class="centered-layout">
      <div class="org-selector">
        <div class="org-selector__header">
          <h1 class="org-selector__title">Cathletics</h1>
          <p class="text-secondary mt-1">Choose an organization</p>
        </div>

        <div class="org-selector__list">
          {{#each @orgs as |entry|}}
            <LinkTo @route="orgs.org.dashboard" @model={{entry.org.slug}} class="org-selector__item">
              <div class="org-selector__name">{{entry.org.name}}</div>
              <UiBadge @variant={{if (eq entry.role "admin") "primary" "default"}}>
                {{entry.role}}
              </UiBadge>
            </LinkTo>
          {{else}}
            <UiCard>
              <p class="text-secondary text-center">You are not a member of any organization yet.</p>
            </UiCard>
          {{/each}}
        </div>
      </div>
    </div>
  </template>
}
