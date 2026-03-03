import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import routerViewTransition from 'frontend/modifiers/router-view-transition';

export default class OrgShell extends Component {
  @service session;
  @service theme;
  @service router;

  @tracked sidebarOpen = false;

  @action
  toggleSidebar() {
    this.sidebarOpen = !this.sidebarOpen;
  }

  @action
  closeSidebar() {
    this.sidebarOpen = false;
  }

  @action
  toggleTheme() {
    this.theme.toggle();
  }

  @action
  logout() {
    this.session.invalidate();
  }

  <template>
    <div class="app-shell">
      {{#if this.sidebarOpen}}
        <div class="sidebar-overlay hide-desktop" role="presentation" {{on "click" this.closeSidebar}}></div>
      {{/if}}

      <aside class="app-sidebar {{if this.sidebarOpen 'is-open'}}">
        <div class="app-sidebar__header">
          <div class="app-sidebar__brand">{{@org.name}}</div>
        </div>

        <nav class="app-sidebar__nav" {{on "click" this.closeSidebar}}>
          <LinkTo @route="orgs.org.dashboard" @model={{@org.slug}} class="app-sidebar__link">
            Dashboard
          </LinkTo>
          <LinkTo @route="orgs.org.activity-types" @model={{@org.slug}} class="app-sidebar__link">
            Activities
          </LinkTo>
          <LinkTo @route="orgs.org.members" @model={{@org.slug}} class="app-sidebar__link">
            Members
          </LinkTo>
          <LinkTo @route="orgs.org.families" @model={{@org.slug}} class="app-sidebar__link">
            Families
          </LinkTo>
          <LinkTo @route="orgs.org.settings" @model={{@org.slug}} class="app-sidebar__link">
            Settings
          </LinkTo>
        </nav>

        <div class="app-sidebar__footer">
          <button type="button" class="app-sidebar__link" {{on "click" this.toggleTheme}}>
            {{if this.theme.isDark "Light Mode" "Dark Mode"}}
          </button>
          <LinkTo @route="orgs" class="app-sidebar__link">
            Switch Org
          </LinkTo>
          <button type="button" class="app-sidebar__link" {{on "click" this.logout}}>
            Sign Out
          </button>
        </div>
      </aside>

      <div class="app-main">
        <header class="app-topbar">
          <button type="button" class="topbar-menu-btn hide-desktop" {{on "click" this.toggleSidebar}}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="3" y1="6" x2="21" y2="6" />
              <line x1="3" y1="12" x2="21" y2="12" />
              <line x1="3" y1="18" x2="21" y2="18" />
            </svg>
          </button>
          <div class="topbar-user">
            {{this.session.currentUser.displayName}}
          </div>
        </header>

        <div id="router-view-transition-container" {{routerViewTransition}}>
          <main class="app-content">
            {{yield}}
          </main>
        </div>
      </div>
    </div>
  </template>
}
