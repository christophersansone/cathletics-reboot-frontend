import Component from '@glimmer/component';
import { args } from 'frontend/utils/stdlib';
import { UiCard } from 'frontend/components/ui';
import { PageHeader } from 'frontend/components/layout';

@args({
  stats: { required: true },
  org: { required: true },
})
export default class DashboardPage extends Component {
  <template>
    <PageHeader>
      <:title>Dashboard</:title>
      <:description>Overview of {{@org.name}}</:description>
    </PageHeader>

    <div class="dashboard-grid">
      <UiCard @title="Active Seasons">
        <div class="stat-value">{{@stats.activeSeasons}}</div>
        <div class="stat-label">Seasons currently running</div>
      </UiCard>

      <UiCard @title="Open Registration">
        <div class="stat-value">{{@stats.openRegistration}}</div>
        <div class="stat-label">Leagues accepting signups</div>
      </UiCard>

      <UiCard @title="Total Members">
        <div class="stat-value">{{@stats.totalMembers}}</div>
        <div class="stat-label">Registered in your organization</div>
      </UiCard>

      <UiCard @title="Teams">
        <div class="stat-value">{{@stats.activeTeams}}</div>
        <div class="stat-label">Active teams this season</div>
      </UiCard>
    </div>
  </template>
}
