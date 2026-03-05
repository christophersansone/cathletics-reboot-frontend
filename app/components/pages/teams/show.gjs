import Component from '@glimmer/component';
import { cached, service, on, array, LinkTo, args } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { UiButton } from 'frontend/components/ui';
import { Breadcrumbs, DetailHeader } from 'frontend/components/layout';
import TeamMembershipList from 'frontend/components/team-membership/list';
import TeamMembershipModalComponent, { AddMemberModal } from 'frontend/components/team-membership/modal';

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
  @service pagination;
  @service router;
  @service alerts;
  @service modal;

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

  <template>
    <Breadcrumbs />

    <DetailHeader>
      <:title>{{@team.name}}</:title>
      <:actions>
        <LinkTo @route="orgs.org.teams.team.edit" @models={{array @org.slug @team.id}}>
          <UiButton @variant="ghost" @size="sm">Edit</UiButton>
        </LinkTo>
        <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" this.deleteTeam.perform}}>
          Delete
        </UiButton>
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

    <div class="section-header">
      <h2 class="section-header__title">Roster</h2>
      <UiButton @size="sm" {{on "click" this.addMember.perform}}>Add Member</UiButton>
    </div>

    <TeamMembershipList @paginator={{this.rosterPaginator}} @onCreate={{this.addMember.perform}} />
  </template>
}
