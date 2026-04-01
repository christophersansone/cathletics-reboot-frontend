import Component from '@glimmer/component';
import { cached, service, on, array, LinkTo, args, tracked, eq, action } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton, UiTabs } from 'frontend/components/ui';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';
import TeamMembershipList from 'frontend/components/team-membership/list';
import TeamMembershipModalComponent, { AddMemberModal } from 'frontend/components/team-membership/modal';
import ScheduleTab from 'frontend/components/team/schedule-tab';

@args({
  team: { required: true },
  league: { required: true },
  season: { required: true },
  activityType: { required: true },
  org: { required: true },
})
export default class TeamShowPage extends Component {
  @service atomic;
  @service store;
  @service session;
  @service cache;
  @service pagination;
  @service router;
  @service alerts;
  @service modal;

  @tracked activeTab = 'Roster';

  @cached
  get fetchOrganizationRoleTaskInstance() {
    return this.fetchOrganizationRole.perform(this.args.org);
  }

  fetchOrganizationRole = task(async (org) => {
    return await this.session.organizationRoleFor(org);
  });

  @cached
  get organizationRole() {
    return this.fetchOrganizationRoleTaskInstance.value;
  }

  get isOrgAdmin() {
    return this.organizationRole === 'admin';
  }

  @cached
  get hasStaffRoleOnTeam() {
    const members = this.cache.get(`team-${this.args.team.id}-associated-members`) ?? [];
    const roles = new Set(['coach', 'assistant_coach', 'manager']);
    return members.some((m) => roles.has(m.role));
  }

  @cached
  get canManageRoster() {
    return this.isOrgAdmin || this.hasStaffRoleOnTeam;
  }

  @cached
  get rosterOnCreate() {
    return this.canManageRoster ? this.addMember.perform : undefined;
  }

  @cached
  get rosterPaginator() {
    return this.pagination.query('team-membership', { team_id: this.args.team.id });
  }

  deleteTeam = task(async () => {
    const confirmed = await this.modal.confirm(`Delete team "${this.args.team.name}"?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(this.args.team);
    this.alerts.success('Team deleted.');
    this.router.transitionTo('orgs.org.leagues.league', this.args.org.slug, this.args.league.id);
  });

  addMember = task({ drop: true }, async () => {
    const modalDialog = new AddMemberModal({
      team: this.args.team,
      atomic: this.atomic,
      onSearch: (query) => this.searchUsers.perform(query),
    });
    const result = await this.modal.execute(modalDialog, TeamMembershipModalComponent);
    if (result.model) {
      this.alerts.success('Member added.');
      await this.rosterPaginator.reload();
    }
  });

  searchUsers = task({ restartable: true }, async (query) => {
    const results = await this.store.query('user', { q: query });
    return results.slice();
  });

  @action
  setActiveTab(tab) {
    this.activeTab = tab;
  }

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>{{@team.name}}</:title>
      <:actions>
        {{#if this.isOrgAdmin}}
          <LinkTo @route="orgs.org.teams.team.edit" @models={{array @org.slug @team.id}}>
            <UiButton @variant="ghost" @size="sm">Edit</UiButton>
          </LinkTo>
          <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" this.deleteTeam.perform}}>
            Delete
          </UiButton>
        {{/if}}
      </:actions>
      <:meta as |Meta|>
        <Meta @label="League">
          <LinkTo @route="orgs.org.leagues.league" @models={{array @org.slug @league.id}} class="text-link">
            {{@league.name}}
          </LinkTo>
        </Meta>
        <Meta @label="Season" @value={{@season.name}} />
        <Meta @label="Activity" @value={{@activityType.name}} />
      </:meta>
    </DetailHeader>

    <UiTabs @activeTab={{this.activeTab}} @tabs={{array 'Roster' 'Schedule'}} @onChange={{this.setActiveTab}}>
      <:tab as |activeTab|>
        {{activeTab}}
      </:tab>
      <:content as |activeTab|>
        {{#if (eq activeTab "Roster")}}
          <div class="section-header">
            <h2 class="section-header__title">Roster</h2>
            {{#if this.canManageRoster}}
              <UiButton @size="sm" {{on "click" this.addMember.perform}}>Add Member</UiButton>
            {{/if}}
          </div>
          <TeamMembershipList @paginator={{this.rosterPaginator}} @onCreate={{this.rosterOnCreate}} />
        {{else}}
          <ScheduleTab @team={{@team}} />
        {{/if}}
      </:content>
    </UiTabs>
  </template>
}
