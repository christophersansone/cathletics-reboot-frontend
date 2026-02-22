import Component from '@glimmer/component';

const VARIANTS = {
  default: 'badge--default',
  primary: 'badge--primary',
  success: 'badge--success',
  warning: 'badge--warning',
  danger: 'badge--danger',
  info: 'badge--info',
};

export default class UiBadge extends Component {
  get classes() {
    return `badge ${VARIANTS[this.args.variant ?? 'default']}`;
  }

  <template>
    <span class={{this.classes}} ...attributes>{{yield}}</span>
  </template>
}
