import Component from '@glimmer/component';

export default class UiCard extends Component {
  get classes() {
    let cls = 'card';
    if (this.args.padding === false) cls += ' card--no-pad';
    return cls;
  }

  <template>
    <div class={{this.classes}} ...attributes>
      {{#if @title}}
        <div class="card__header">
          <h3 class="card__title">{{@title}}</h3>
          {{#if (has-block "actions")}}
            <div class="card__actions">{{yield to="actions"}}</div>
          {{/if}}
        </div>
      {{/if}}
      <div class="card__body">
        {{yield}}
      </div>
    </div>
  </template>
}
