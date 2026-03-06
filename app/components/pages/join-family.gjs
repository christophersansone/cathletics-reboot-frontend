import Component from '@glimmer/component';
import { tracked, action, service, on, args, Await } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiCard } from 'frontend/components/ui';

const ROLE_LABELS = {
  parent: 'Parent',
  guardian: 'Guardian',
  viewer: 'Viewer (read-only)',
};

@args({
  invitation: { required: true },
})
export default class JoinFamilyPage extends Component {
  @service store;
  @service router;
  @service alerts;
  @service session;

  @tracked error = null;

  get roleLabel() {
    return ROLE_LABELS[this.args.invitation.role] || this.args.invitation.role;
  }

  @action goToLogin() {
    this.session.attemptedTransition = {
      retry: () => this.router.transitionTo('join-family', this.args.invitation.token),
    };
    this.router.transitionTo('login');
  }

  @action goToSignup() {
    this.session.attemptedTransition = {
      retry: () => this.router.transitionTo('join-family', this.args.invitation.token),
    };
    this.router.transitionTo('signup');
  }

  acceptTask = task({ drop: true }, async () => {
    this.error = null;
    try {
      const adapter = this.store.adapterFor('family-invitation');
      await adapter.accept(this.args.invitation);
      this.alerts.success('You have joined the family!');
      this.router.transitionTo('my-family');
    } catch (e) {
      this.error = e.message || 'Something went wrong. Please try again.';
    }
  });

  <template>
    <div class="centered-layout">
      <div class="login-container">
        <div class="login-logo">
          <h1 class="login-title">Cathletics</h1>
          <p class="text-secondary">You've been invited to join a family</p>
        </div>

        <UiCard>
          <div class="flex flex-col gap-4 items-center text-center">
            <Await @promise={{@invitation.family}} as |family|>
              <h2 class="text-xl font-semibold">{{family.name}}</h2>
            </Await>
            <p class="text-secondary">
              You'll be added as:
              <strong>{{this.roleLabel}}</strong>
            </p>

            {{#if this.error}}
              <div class="login-error w-full">{{this.error}}</div>
            {{/if}}

            {{#if this.session.isAuthenticated}}
              <UiButton
                @full={{true}}
                @loading={{this.acceptTask.isRunning}}
                disabled={{this.acceptTask.isRunning}}
                {{on "click" this.acceptTask.perform}}
              >
                Join Family
              </UiButton>
            {{else}}
              <p class="text-secondary text-sm">Sign in or create an account to accept this invitation.</p>
              <div class="flex flex-col gap-2 w-full">
                <UiButton @full={{true}} {{on "click" this.goToLogin}}>
                  Sign In
                </UiButton>
                <UiButton @full={{true}} @variant="secondary" {{on "click" this.goToSignup}}>
                  Create Account
                </UiButton>
              </div>
            {{/if}}
          </div>
        </UiCard>
      </div>
    </div>
  </template>
}
