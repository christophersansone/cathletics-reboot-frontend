import Component from '@glimmer/component';

export default class UiInput extends Component {
  get inputClasses() {
    let cls = 'form-input';
    if (this.args.error) cls += ' is-invalid';
    return cls;
  }

  <template>
    <div class="form-group">
      {{#if @label}}
        <label class="form-label" for={{@id}}>{{@label}}</label>
      {{/if}}
      <input
        id={{@id}}
        type={{if @type @type "text"}}
        value={{@value}}
        placeholder={{@placeholder}}
        class={{this.inputClasses}}
        autocomplete={{@autocomplete}}
        ...attributes
      />
      {{#if @error}}
        <span class="form-error">{{@error}}</span>
      {{/if}}
      {{#if @hint}}
        <span class="form-hint">{{@hint}}</span>
      {{/if}}
    </div>
  </template>
}
