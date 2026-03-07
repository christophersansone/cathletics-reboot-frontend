import Component from '@glimmer/component';
import { cached, args, Await } from 'frontend/utils/stdlib';
import { UiBadge } from 'frontend/components/ui';
import { service } from '@ember/service';

const ROLE_LABELS = {
  player: 'Player',
  coach: 'Coach',
  assistant_coach: 'Asst. Coach',
  manager: 'Manager',
};

const ROLE_VARIANTS = {
  coach: 'info',
  assistant_coach: 'info',
  manager: 'warning',
};

function roleLabel(role) {
  return ROLE_LABELS[role] || role;
}

function roleVariant(role) {
  return ROLE_VARIANTS[role] || 'default';
}

@args({
  team: { required: true },
})
export default class RosterTab extends Component {
  @service pagination;

  @cached
  get membershipsPaginator() {
    return this.pagination.hasMany(this.args.team, 'teamMemberships');
  }

  get memberships() {
    return this.membershipsPaginator.displayItems;
  }

  get coaches() {
    return this.memberships.filter((m) => m.role === 'coach' || m.role === 'assistant_coach' || m.role === 'manager');
  }

  get players() {
    return this.memberships.filter((m) => m.role === 'player');
  }

  <template>
    <Await @promise={{this.membershipsPaginator.firstPage}} @showLatest={{true}}>
      {{#if this.coaches.length}}
        <div class="roster-section">
          <h3 class="roster-section__title">Coaches & Staff</h3>
          <ul class="roster-list">
            {{#each this.coaches as |membership|}}
              <li class="roster-list__item">
                <Await @promise={{membership.user}} as |user|>
                  <span class="roster-list__name">{{user.fullName}}</span>
                </Await>
                <UiBadge @variant={{roleVariant membership.role}}>{{roleLabel membership.role}}</UiBadge>
              </li>
            {{/each}}
          </ul>
        </div>
      {{/if}}

      {{#if this.players.length}}
        <div class="roster-section players">
          <h3 class="roster-section__title">Players</h3>
          <ul class="roster-list">
            {{#each this.players as |membership|}}
              <li class="roster-list__item">
                {{#if membership.uniformNumber}}
                  <span class="roster-list__number">{{membership.uniformNumber}}</span>
                {{/if}}
                <Await @promise={{membership.user}} as |user|>
                  <span class="roster-list__name">{{user.fullName}}</span>
                </Await>
                {{#if membership.position}}
                  <span class="roster-list__position">{{membership.position}}</span>
                {{/if}}
              </li>
            {{/each}}
          </ul>
        </div>
      {{/if}}

      {{#unless this.memberships.length}}
        <p class="text-secondary text-sm text-center py-8">No members on this team yet.</p>
      {{/unless}}
    </Await>
  </template>
}
