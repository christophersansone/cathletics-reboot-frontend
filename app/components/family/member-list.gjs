import Component from '@glimmer/component';
import { on, fn, Await, args } from 'frontend/utils/stdlib';
import { UiButton } from 'frontend/components/ui';
import { gradeLabel } from 'frontend/components/ui/grade-level-select';
import Paginator from 'frontend/utils/paginator';

function roleLabel(role) {
  if (role === 'guardian') return 'Guardian';
  if (role === 'parent') return 'Parent';
  if (role === 'child') return 'Child';
  return role;
}

@args({
  paginator: { type: Paginator, required: true },
  onAddChild: { type: 'function' },
  onEditChild: { type: 'function' },
  onRemoveChild: { type: 'function' },
})
export default class FamilyMemberList extends Component {
  get memberships() {
    return this.args.paginator.displayItems;
  }

  get parents() {
    return this.memberships.filter((m) => m.role === 'parent' || m.role === 'guardian');
  }

  get children() {
    return this.memberships.filter((m) => m.role === 'child');
  }

  <template>
    <Await @promise={{@paginator.firstPage}} @showLatest={{true}}>
      {{#if this.parents.length}}
        <div class="mb-4">
          <h3 class="text-sm font-medium text-secondary mb-2">Parents / Guardians</h3>
          <ul class="member-list">
            {{#each this.parents as |membership|}}
              <li class="member-list__item">
                <span class="font-medium">{{membership.user.fullName}}</span>
                <span class="text-secondary text-sm">{{roleLabel membership.role}}</span>
              </li>
            {{/each}}
          </ul>
        </div>
      {{/if}}

      <div>
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-sm font-medium text-secondary">Children</h3>
          {{#if @onAddChild}}
            <UiButton @size="sm" {{on "click" @onAddChild}}>Add Child</UiButton>
          {{/if}}
        </div>

        {{#if this.children.length}}
          <ul class="member-list">
            {{#each this.children as |membership|}}
              <li class="member-list__item">
                <div class="flex-1">
                  <span class="font-medium">{{membership.user.fullName}}</span>
                  <span class="text-secondary text-sm">
                    {{#if membership.user.gradeLevel}}{{gradeLabel membership.user.gradeLevel}}{{/if}}
                    {{#if membership.user.gender}} · {{membership.user.gender}}{{/if}}
                  </span>
                </div>
                <div class="flex gap-2">
                  {{#if @onEditChild}}
                    <UiButton @variant="ghost" @size="sm" {{on "click" (fn @onEditChild membership)}}>Edit</UiButton>
                  {{/if}}
                  {{#if @onRemoveChild}}
                    <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn @onRemoveChild membership)}}>Remove</UiButton>
                  {{/if}}
                </div>
              </li>
            {{/each}}
          </ul>
        {{else}}
          <p class="text-secondary text-sm">No children added yet. Add your children to register them for activities.</p>
        {{/if}}
      </div>
    </Await>
  </template>
}
