import Component from '@glimmer/component';

export default class UiSelect extends Component {
  get selectClasses() {
    let cls = 'form-select';
    if (this.args.error) cls += ' is-invalid';
    return cls;
  }

  <template>
    <div class="form-group">
      {{#if @label}}
        <label class="form-label" for={{@id}}>{{@label}}</label>
      {{/if}}
      <select
        id={{@id}}
        class={{this.selectClasses}}
        ...attributes
      >
        {{#if @placeholder}}
          <option value="" disabled selected={{this.isBlank}}>{{@placeholder}}</option>
        {{/if}}
        {{yield}}
      </select>
      {{#if @error}}
        <span class="form-error">{{@error}}</span>
      {{/if}}
      {{#if @hint}}
        <span class="form-hint">{{@hint}}</span>
      {{/if}}
    </div>
  </template>
}
