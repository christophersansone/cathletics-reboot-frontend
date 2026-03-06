import Component from '@glimmer/component';
import { service, on, LinkTo } from 'frontend/utils/stdlib';

const HomeIcon = <template>
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
    <path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9.5z" />
    <polyline points="9 21 9 14 15 14 15 21" />
  </svg>
</template>;

const RegisterIcon = <template>
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
    <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2" />
    <rect x="9" y="3" width="6" height="4" rx="1" />
    <path d="M9 14l2 2 4-4" />
  </svg>
</template>;

const ScheduleIcon = <template>
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
    <rect x="3" y="4" width="18" height="18" rx="2" />
    <line x1="16" y1="2" x2="16" y2="6" />
    <line x1="8" y1="2" x2="8" y2="6" />
    <line x1="3" y1="10" x2="21" y2="10" />
    <rect x="8" y="14" width="3" height="3" rx="0.5" />
  </svg>
</template>;

const AccountIcon = <template>
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="8" r="4" />
    <path d="M20 21a8 8 0 1 0-16 0" />
  </svg>
</template>;

export default class MemberShell extends Component {
  @service session;

  <template>
    <div class="member-shell">
      <header class="member-topbar">
        <span class="member-topbar__brand">Cathletics</span>
        <span class="member-topbar__user">{{this.session.currentUser.displayName}}</span>
      </header>

      <aside class="member-sidebar">
        <div class="member-sidebar__header">
          <span class="member-sidebar__brand">Cathletics</span>
        </div>
        <nav class="member-sidebar__nav">
          <LinkTo @route="home" class="member-sidebar__link">
            <HomeIcon />
            Home
          </LinkTo>
          <LinkTo @route="register" class="member-sidebar__link">
            <RegisterIcon />
            Register
          </LinkTo>
          <LinkTo @route="schedule" class="member-sidebar__link">
            <ScheduleIcon />
            Schedule
          </LinkTo>
          <LinkTo @route="account" class="member-sidebar__link">
            <AccountIcon />
            Account
          </LinkTo>
        </nav>
        <div class="member-sidebar__footer">
          <span class="member-sidebar__user">{{this.session.currentUser.displayName}}</span>
        </div>
      </aside>

      <main class="member-content">
        {{yield}}
      </main>

      <nav class="member-tabbar" aria-label="Main navigation">
        <LinkTo @route="home" class="member-tab">
          <HomeIcon />
          <span>Home</span>
        </LinkTo>
        <LinkTo @route="register" class="member-tab">
          <RegisterIcon />
          <span>Register</span>
        </LinkTo>
        <LinkTo @route="schedule" class="member-tab">
          <ScheduleIcon />
          <span>Schedule</span>
        </LinkTo>
        <LinkTo @route="account" class="member-tab">
          <AccountIcon />
          <span>Account</span>
        </LinkTo>
      </nav>
    </div>
  </template>
}
