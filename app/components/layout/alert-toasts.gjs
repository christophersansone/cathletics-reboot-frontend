import Component from '@glimmer/component';
import { service, fn } from 'frontend/utils/stdlib';
import { UiAlert } from 'frontend/components/ui';

export default class AlertToasts extends Component {
  @service alerts;

  <template>
    {{#if this.alerts.items.length}}
      <div class="alert-toasts">
        {{#each this.alerts.items as |alert|}}
          <UiAlert
            @variant={{alert.variant}}
            @timeout={{alert.timeout}}
            @onDismiss={{fn this.alerts.dismiss alert}}
          >
            {{alert.message}}
          </UiAlert>
        {{/each}}
      </div>
    {{/if}}
  </template>
}
