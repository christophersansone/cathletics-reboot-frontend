import Component from '@glimmer/component';
import { service } from '@ember/service';
import { fn } from '@ember/helper';
import UiAlert from './ui/alert';

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
