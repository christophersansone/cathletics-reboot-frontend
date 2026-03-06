import Component from '@glimmer/component';
import { UiCard } from 'frontend/components/ui';

export default class SchedulePage extends Component {
  <template>
    <div class="member-page">
      <h1 class="member-page__title">Schedule</h1>
      <UiCard>
        <div class="flex flex-col gap-2 items-center text-center py-8">
          <p class="text-lg font-semibold">Upcoming Events</p>
          <p class="text-secondary text-sm">View games, practices, and events for your family members.</p>
          <p class="text-secondary text-sm mt-4">Coming soon.</p>
        </div>
      </UiCard>
    </div>
  </template>
}
