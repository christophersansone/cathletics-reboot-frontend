import Component from '@glimmer/component';
import { UiCard } from 'frontend/components/ui';

export default class ScheduleTab extends Component {
  <template>
    <UiCard>
      <div class="flex flex-col gap-2 items-center text-center py-8">
        <p class="text-lg font-semibold">Schedule</p>
        <p class="text-secondary text-sm">Games, practices, and events for this team will appear here.</p>
        <p class="text-secondary text-sm mt-4">Coming soon.</p>
      </div>
    </UiCard>
  </template>
}
