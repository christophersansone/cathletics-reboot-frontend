import Component from '@glimmer/component';
import { service, action, on, LinkTo } from 'frontend/utils/stdlib';
import { UiCard } from 'frontend/components/ui';

export default class AccountPage extends Component {
  @service session;
  @service theme;

  @action toggleTheme() {
    this.theme.toggle();
  }

  <template>
    <div class="member-page">
      <h1 class="member-page__title">Account</h1>

      <UiCard @title="Profile">
        <div class="account-info">
          <div class="account-info__row">
            <span class="text-secondary text-sm">Name</span>
            <span class="font-medium">{{this.session.currentUser.fullName}}</span>
          </div>
          <div class="account-info__row">
            <span class="text-secondary text-sm">Email</span>
            <span class="font-medium">{{this.session.currentUser.email}}</span>
          </div>
        </div>
      </UiCard>

      <UiCard @title="Navigation">
        <nav class="account-nav">
          <LinkTo @route="my-family" class="account-nav__link">
            <span>My Family</span>
            <span class="account-nav__chevron">&rsaquo;</span>
          </LinkTo>
          <LinkTo @route="orgs" class="account-nav__link">
            <span>My Organizations</span>
            <span class="account-nav__chevron">&rsaquo;</span>
          </LinkTo>
        </nav>
      </UiCard>

      <UiCard @title="Preferences">
        <div class="account-nav">
          <button type="button" class="account-nav__link" {{on "click" this.toggleTheme}}>
            <span>{{if this.theme.isDark "Switch to Light Mode" "Switch to Dark Mode"}}</span>
            <span class="account-nav__chevron">&rsaquo;</span>
          </button>
        </div>
      </UiCard>

      <div class="account-signout">
        <button type="button" class="text-link text-danger" {{on "click" this.session.invalidate}}>
          Sign Out
        </button>
      </div>
    </div>
  </template>
}
