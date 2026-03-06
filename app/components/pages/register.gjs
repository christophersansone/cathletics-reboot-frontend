import Component from '@glimmer/component';
import { UiCard } from 'frontend/components/ui';

export default class RegisterPage extends Component {
  <template>
    <div class="member-page">
      <h1 class="member-page__title">Register</h1>
      <UiCard>
        <div class="flex flex-col gap-2 items-center text-center py-8">
          <p class="text-lg font-semibold">Browse & Register</p>
          <p class="text-secondary text-sm">Browse open registration windows and sign up your family members for activities.</p>
          <p class="text-secondary text-sm mt-4">Coming soon.</p>
        </div>
      </UiCard>
    </div>
  </template>
}
