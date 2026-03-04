import Component from '@glimmer/component';
import { tracked, action } from 'frontend/utils/stdlib';
import { UiTypeableSelect } from 'frontend/components/ui';

const OPTIONS = [ { name: 'Tom' }, { name: 'Dave' }, { name: 'Stephen' } ];

export default class TypeableSelectExampleComponent extends Component {
  @tracked selected = null;

  @action
  changed(value) {
    this.selected = value;
  }

  @action
  async search(q) {
    await new Promise((resolve) => window.setTimeout(resolve, 1000));
    return OPTIONS.filter((o) => o.name.toLowerCase().includes(q.toLowerCase()));
  }

  <template>
    <UiTypeableSelect @options={{OPTIONS}} @path="name" @selected={{this.selected}} @onChange={{this.changed}} @onSearch={{this.search}} />
  </template>
}
