import Component from '@glimmer/component';

const VARIANTS = {
  primary: 'btn-primary',
  secondary: 'btn-secondary',
  ghost: 'btn-ghost',
  danger: 'btn-danger',
};

const SIZES = {
  sm: 'btn-sm',
  md: 'btn-md',
  lg: 'btn-lg',
};

export default class UiButton extends Component {
  get classes() {
    let cls = `btn ${VARIANTS[this.args.variant ?? 'primary']} ${SIZES[this.args.size ?? 'md']}`;
    if (this.args.block) cls += ' btn-block';
    return cls;
  }

  <template>
    {{#if @href}}
      <a href={{@href}} class={{this.classes}} ...attributes>{{yield}}</a>
    {{else}}
      <button type={{if @type @type "button"}} class={{this.classes}} ...attributes>
        {{#if @loading}}
          <span class="btn-spinner" />
        {{/if}}
        {{yield}}
      </button>
    {{/if}}
  </template>
}
