import Component from '@glimmer/component';

export default class ActivityTypesPage extends Component {
  <template>
    <div class="page-header">
      <h1 class="page-header__title">Activities</h1>
      <p class="page-header__description">Manage activity types, seasons, and leagues</p>
    </div>

    {{yield}}
  </template>
}
