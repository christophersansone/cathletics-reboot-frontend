import Component from '@glimmer/component';
import { args, LinkTo } from 'frontend/utils/stdlib';
import { UiCard, UiBadge } from 'frontend/components/ui';

const STATUS_VARIANTS = {
  confirmed: 'success',
  pending: 'warning',
  waitlisted: 'info',
};

function statusLabel(status) {
  return status.charAt(0).toUpperCase() + status.slice(1);
}

function statusVariant(status) {
  return STATUS_VARIANTS[status] || 'default';
}

function groupByOrg(items) {
  const groups = new Map();
  for (const item of items) {
    const orgId = item.organization.id;
    if (!groups.has(orgId)) {
      groups.set(orgId, { organization: item.organization, items: [] });
    }
    groups.get(orgId).items.push(item);
  }
  return [...groups.values()];
}

@args({
  activeRegistrations: { required: true },
  openLeagues: { required: true },
})
export default class HomePage extends Component {
  get registrationGroups() {
    return groupByOrg(this.args.activeRegistrations);
  }

  get leagueGroups() {
    return groupByOrg(this.args.openLeagues);
  }

  get hasRegistrations() {
    return this.args.activeRegistrations.length > 0;
  }

  get hasOpenLeagues() {
    return this.args.openLeagues.length > 0;
  }

  <template>
    <div class="member-page">
      <section class="home-section">
          <h2 class="home-section__title">My Activities</h2>

          {{#if this.hasRegistrations}}
            {{#each this.registrationGroups as |group|}}
              <UiCard @title={{group.organization.name}}>
                <ul class="activity-list">
                  {{#each group.items as |reg|}}
                    <li class="activity-list__item">
                      <div class="activity-list__main">
                        {{#if reg.team}}
                          <LinkTo @route="teams.team" @model={{reg.team.id}} class="activity-list__name activity-list__link">
                            {{reg.activityType.name}}: {{reg.league.name}}
                          </LinkTo>
                        {{else}}
                          <span class="activity-list__name">{{reg.activityType.name}}: {{reg.league.name}}</span>
                        {{/if}}
                        <span class="text-secondary text-sm">
                          {{reg.season.name}}
                          {{#if reg.team}}
                            &middot; {{reg.team.name}}
                          {{/if}}
                        </span>
                      </div>
                      <div class="activity-list__meta">
                        <span class="text-sm">{{reg.user.fullName}}</span>
                        <UiBadge @variant={{statusVariant reg.status}}>{{statusLabel reg.status}}</UiBadge>
                      </div>
                    </li>
                  {{/each}}
                </ul>
              </UiCard>
            {{/each}}
          {{else}}
            <UiCard>
              <p class="text-secondary text-sm text-center">No active registrations. Browse open registration below, or <LinkTo @route="my-family" class="text-link">manage your family</LinkTo> first.</p>
            </UiCard>
          {{/if}}
        </section>

        <section class="home-section">
          <h2 class="home-section__title">Open Registration</h2>

          {{#if this.hasOpenLeagues}}
            {{#each this.leagueGroups as |group|}}
              <UiCard @title={{group.organization.name}}>
                <ul class="activity-list">
                  {{#each group.items as |league|}}
                    <li class="activity-list__item">
                      <div class="activity-list__main">
                        <span class="activity-list__name">{{league.activityType.name}}: {{league.name}}</span>
                        <span class="text-secondary text-sm">{{league.season.name}}</span>
                      </div>
                      <div class="activity-list__meta">
                        <span class="text-secondary text-sm">
                          {{#each league.eligibleMembers as |member index|}}
                            {{if index ", "}}{{member.fullName}}
                          {{/each}}
                        </span>
                        {{#if league.full}}
                          <UiBadge @variant="warning">Full</UiBadge>
                        {{else}}
                          <UiBadge @variant="success">Open</UiBadge>
                        {{/if}}
                      </div>
                    </li>
                  {{/each}}
                </ul>
              </UiCard>
            {{/each}}
          {{else}}
            <UiCard>
              <p class="text-secondary text-sm text-center">No registration windows are currently open.</p>
            </UiCard>
          {{/if}}
        </section>
    </div>
  </template>

}
