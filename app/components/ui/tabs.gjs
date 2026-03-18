import Component from '@glimmer/component';
import { args, eq, on, fn } from 'frontend/utils/stdlib';

@args({
  tabs: { array: true, required: true },
  activeTab: { required: true },
  onChange: { type: 'function', required: true },
})
export default class UiTabsComponent extends Component {
  <template>
    <nav class="tabs flex gap-2 border-b border-border mb-4">
      {{#each @tabs as |tab|}}
        <button
          type="button"
          class="tab {{if (eq @activeTab tab) "active"}}"
          {{on "click" (fn @onChange tab)}}
        >
          {{yield tab to="tab"}}
        </button>
      {{/each}}
    </nav>

    {{yield @activeTab to="content"}}
  </template>
}
