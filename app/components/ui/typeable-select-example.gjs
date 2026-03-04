import TypeableSelect from 'frontend/components/ui/typeable-select';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

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
    <TypeableSelect @options={{OPTIONS}} @path="name" @selected={{this.selected}} @onChange={{this.changed}} @onSearch={{this.search}} />
  </template>
}
