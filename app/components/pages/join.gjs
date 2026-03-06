import Component from '@glimmer/component';
import { tracked, service, on, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard } from 'frontend/components/ui';

@args({
  org: { required: true },
})
export default class JoinPage extends Component {
  @service store;
  @service router;
  @service alerts;
  @service session;

  @tracked error = null;

  joinTask = task({ drop: true }, async () => {
    this.error = null;
    try {
      const adapter = this.store.adapterFor('application');
      const url = `${adapter.host}/${adapter.namespace}/organizations/${this.args.org.slug}/join`;
      const response = await adapter.ajax(url, 'POST');
      this.store.pushPayload(response);
      this.session.setOrganization(this.args.org);
      this.alerts.success(`Welcome to ${this.args.org.name}!`);
      this.router.transitionTo('orgs.org.dashboard', this.args.org.slug);
    } catch (e) {
      this.error = e.message || 'Something went wrong. Please try again.';
    }
  });

  <template>
    <div class="centered-layout">
      <div class="login-container">
        <div class="login-logo">
          <h1 class="login-title">Cathletics</h1>
          <p class="text-secondary">You've been invited to join</p>
        </div>

        <UiCard>
          <div class="flex flex-col gap-4 items-center text-center">
            <h2 class="text-xl font-semibold">{{@org.name}}</h2>

            {{#if this.error}}
              <div class="login-error w-full">{{this.error}}</div>
            {{/if}}

            <UiButton
              @full={{true}}
              @loading={{this.joinTask.isRunning}}
              disabled={{this.joinTask.isRunning}}
              {{on "click" this.joinTask.perform}}
            >
              Join {{@org.name}}
            </UiButton>
          </div>
        </UiCard>
      </div>
    </div>
  </template>
}
