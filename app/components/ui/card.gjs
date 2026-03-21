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
        <div class="header">
          <h3 class="title">{{@title}}</h3>
          {{#if (has-block "actions")}}
            <div class="actions">{{yield to="actions"}}</div>
          {{/if}}
        </div>
      {{/if}}
      <div class="body">
        {{yield}}
      </div>
    </div>
  </template>
}
