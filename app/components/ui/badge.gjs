import Component from '@glimmer/component';

const VARIANTS = [ 'default', 'primary', 'success', 'warning', 'danger', 'info' ];

export default class UiBadge extends Component {
  get variant() {
    return this.args.variant ?? 'default';
  }

  <template>
    <span class="badge" data-variant={{this.variant}} ...attributes>{{yield}}</span>
  </template>
}
