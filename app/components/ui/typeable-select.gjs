import Component from '@glimmer/component';
import { tracked, cached, on, fn, or, Await, LoadingIndicator, args } from 'frontend/utils/stdlib';
import { modifier } from 'ember-modifier';
import { task, timeout } from 'ember-concurrency';
import { get } from '@ember/object';

/**
 * A simple "click outside" modifier to close the menu
 */
const clickOutside = modifier((element, [callback]) => {
  const handler = (event) => {
    if (!element.contains(event.target)) callback();
  };
  document.addEventListener('click', handler);
  return () => document.removeEventListener('click', handler);
});

@args({
  options: { required: true, isArray: true },
  selected: { required: true },
  // the path from an option to its display value
  path: { type: 'string' },
  onChange: { type: 'function', required: true },
  onSearch: { type: 'function', required: true },
  searchDelay: { type: 'number' },
  placeholder: { type: 'string' },
})
export default class SearchableSelect extends Component {
  @tracked displayValue = '';
  @tracked query = '';
  @tracked isOpen = false;

  searchTask = task({ restartable: true }, async (query) => {
    if (!query) return this.args.options;
    if (this.args.searchDelay) {
      await timeout(this.args.searchDelay);
    }
    return await this.args.onSearch(query);
  })

  @cached
  get searchTaskInstance() {
    return this.searchTask.perform(this.query);
  }

  updateQuery = (event) => {
    this.query = event.target.value;
    this.displayValue = '';
    this.open();
  };

  selectOption = (option) => {
    this.displayValue = this.displayValueFor(option);
    this.isOpen = false;
    this.args.onChange(option);
  };

  close = () => {
    this.isOpen = false;
  };

  open = () => {
    this.isOpen = true;
  };

  displayValueFor(option) {
    return this.args.path ? get(option, this.args.path) : option;
  }

  <template>
    <div class="combobox-container" {{clickOutside this.close}}>
      <input
        type="text"
        value={{or this.displayValue this.query}}
        placeholder={{@placeholder}}
        aria-label={{@placeholder}}
        class="combobox-input"
        {{on "input" this.updateQuery}}
        {{on "focus" this.open}}
         ...attributes
      />

      {{#if this.isOpen}}
        <div class="dropdown">
          <Await @promise={{this.searchTaskInstance}}>
            <:pending>
              <LoadingIndicator class="loading" />
            </:pending>
            <:success as |searchResults|>
              <ul class="combobox-results">
                {{#each searchResults as |option|}}
                  <li>
                    <button
                      type="button"
                      class="combobox-option"
                      {{on "click" (fn this.selectOption option)}}
                    >
                      {{if @path (get option @path) option}}
                    </button>
                  </li>
                {{else}}
                  <li class="empty">(no results)</li>
                {{/each}}
              </ul>
            </:success>
          </Await>
        </div>
      {{/if}}
    </div>
  </template>
}
