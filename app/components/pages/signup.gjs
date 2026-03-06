import Component from '@glimmer/component';
import { tracked, action, service, on, fn, LinkTo } from 'frontend/utils/stdlib';
import { UiButton, UiInput, UiCard } from 'frontend/components/ui';
import viewTransitionName from 'frontend/modifiers/view-transition-name';

export default class SignupPage extends Component {
  @service session;
  @service router;

  @tracked firstName = '';
  @tracked lastName = '';
  @tracked email = '';
  @tracked password = '';
  @tracked passwordConfirmation = '';
  @tracked error = null;
  @tracked isLoading = false;

  @action updateField(field, event) {
    this[field] = event.target.value;
  }

  get passwordMismatch() {
    return this.passwordConfirmation && this.password !== this.passwordConfirmation;
  }

  @action
  async handleSubmit(event) {
    event.preventDefault();
    this.error = null;

    if (this.password !== this.passwordConfirmation) {
      this.error = 'Passwords do not match';
      return;
    }

    this.isLoading = true;

    try {
      await this.session.signup({
        firstName: this.firstName,
        lastName: this.lastName,
        email: this.email,
        password: this.password,
      });
      let attempted = this.session.attemptedTransition;
      if (attempted) {
        this.session.attemptedTransition = null;
        attempted.retry();
      } else {
        this.router.transitionTo('orgs');
      }
    } catch (e) {
      this.error = e.message;
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="centered-layout">
      <div class="login-container">
        <div class="login-logo" {{viewTransitionName 'header'}}>
          <h1 class="login-title">Cathletics</h1>
          <p class="text-secondary" {{viewTransitionName 'reel'}}>Create your account</p>
        </div>

        <UiCard>
          <div class="flex flex-col gap-3 mb-4" {{viewTransitionName 'signup-grow-1'}}>
            <button type="button" class="social-btn social-btn--apple" disabled>
              <svg class="social-btn__icon" viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.48-3.24 0-1.44.62-2.2.44-3.06-.4C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/></svg>
              Sign up with Apple
            </button>
            <button type="button" class="social-btn social-btn--google" disabled>
              <svg class="social-btn__icon" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg>
              Sign up with Google
            </button>
          </div>

          <div class="auth-divider"{{viewTransitionName 'signup-grow-2'}}>
            <span>or</span>
          </div>

          <form class="flex flex-col gap-4" {{on "submit" this.handleSubmit}}>
            {{#if this.error}}
              <div class="login-error">{{this.error}}</div>
            {{/if}}

            <div class="form-row" {{viewTransitionName 'signup-grow-3'}}>
              <UiInput
                @label="First Name"
                @value={{this.firstName}}
                @placeholder="Jane"
                @autocomplete="given-name"
                @id="first-name"
                {{on "input" (fn this.updateField "firstName")}}
              />
              <UiInput
                @label="Last Name"
                @value={{this.lastName}}
                @placeholder="Smith"
                @autocomplete="family-name"
                @id="last-name"
                {{on "input" (fn this.updateField "lastName")}}
              />
            </div>

            <UiInput
              @label="Email"
              @type="email"
              @value={{this.email}}
              @placeholder="you@example.com"
              @autocomplete="email"
              @id="email"
              @viewTransitionName="email"
              {{on "input" (fn this.updateField "email")}}
            />

            <UiInput
              @label="Password"
              @type="password"
              @value={{this.password}}
              @placeholder="Create a password"
              @autocomplete="new-password"
              @id="password"
              @viewTransitionName="password"
              {{on "input" (fn this.updateField "password")}}
            />

            <UiInput
              @label="Confirm Password"
              @type="password"
              @value={{this.passwordConfirmation}}
              @placeholder="Confirm your password"
              @autocomplete="new-password"
              @id="password-confirmation"
              @viewTransitionName="signup-grow-4"
              {{on "input" (fn this.updateField "passwordConfirmation")}}
            />

            {{#if this.passwordMismatch}}
              <p class="form-error">Passwords do not match</p>
            {{/if}}

            <UiButton @type="submit" @full={{true}} @loading={{this.isLoading}} disabled={{this.isLoading}} {{viewTransitionName 'submit'}}>
              Create Account
            </UiButton>
          </form>
        </UiCard>

        <p class="auth-footer" {{viewTransitionName 'switch'}}>
          Already have an account?
          <LinkTo @route="login" class="text-link">Sign in</LinkTo>
        </p>
      </div>
    </div>
  </template>
}
