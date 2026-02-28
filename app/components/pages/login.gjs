import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import UiButton from 'frontend/components/ui/button';
import UiInput from 'frontend/components/ui/input';
import UiCard from 'frontend/components/ui/card';

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
      this.router.transitionTo('orgs');
    } catch (e) {
      this.error = e.message;
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="centered-layout">
      <div class="login-container">
        <div class="login-logo">
          <h1 class="login-title">Cathletics</h1>
          <p class="text-secondary">Sign in to manage your activities</p>
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
              {{on "input" this.updateEmail}}
            />

            <UiInput
              @label="Password"
              @type="password"
              @value={{this.password}}
              @placeholder="Enter your password"
              @autocomplete="current-password"
              @id="password"
              {{on "input" this.updatePassword}}
            />

            <UiButton @type="submit" @block={{true}} @loading={{this.isLoading}} disabled={{this.isLoading}}>
              Sign In
            </UiButton>
          </form>
        </UiCard>
      </div>
    </div>
  </template>
}
