import Component from '@glimmer/component';
import { tracked, action, service, on, LinkTo } from 'frontend/utils/stdlib';
import { UiButton, UiInput, UiCard } from 'frontend/components/ui';
import viewTransitionName from 'frontend/modifiers/view-transition-name';

export default class LoginPage extends Component {
  @service session;
  @service router;

  @tracked email = '';
  @tracked password = '';
  @tracked error = null;
  @tracked isLoading = false;

  @action
  updateEmail(event) {
    this.email = event.target.value;
  }

  @action
  updatePassword(event) {
    this.password = event.target.value;
  }

  @action
  async handleSubmit(event) {
    event.preventDefault();
    this.error = null;
    this.isLoading = true;

    try {
      await this.session.authenticate(this.email, this.password);
      let attempted = this.session.attemptedTransition;
      if (attempted) {
        this.session.attemptedTransition = null;
        attempted.retry();
      } else {
        this.router.transitionTo('home');
      }
    } catch (e) {
      this.error = e.message;
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="centered-layout" ...attributes>
      <div class="login-container">
        <div class="login-logo" {{viewTransitionName 'header'}}>
          <h1 class="login-title">Cathletics</h1>
          <p class="text-secondary" {{viewTransitionName 'reel'}}>Sign in to manage your activities</p>
        </div>

        <UiCard>
          <form class="flex flex-col gap-4" {{on "submit" this.handleSubmit}}>
            {{#if this.error}}
              <div class="login-error">{{this.error}}</div>
            {{/if}}

            <UiInput
              @label="Email"
              @type="email"
              @value={{this.email}}
              @placeholder="you@example.com"
              @autocomplete="email"
              @id="email"
              @viewTransitionName="email"
              {{on "input" this.updateEmail}}
            />

            <UiInput
              @label="Password"
              @type="password"
              @value={{this.password}}
              @placeholder="Enter your password"
              @autocomplete="current-password"
              @id="password"
              @viewTransitionName="password"
              {{on "input" this.updatePassword}}
            />

            <UiButton @type="submit" @full={{true}} @loading={{this.isLoading}} disabled={{this.isLoading}} {{viewTransitionName 'submit'}}>
              Sign In
            </UiButton>
          </form>
        </UiCard>

        <p class="auth-footer" {{viewTransitionName 'switch'}}>
          Don't have an account?
          <LinkTo @route="signup" class="text-link">Create one</LinkTo>
        </p>
      </div>
    </div>
  </template>
}
