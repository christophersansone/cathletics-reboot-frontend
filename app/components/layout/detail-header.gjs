import Component from '@glimmer/component';
import viewTransitionName from 'frontend/modifiers/view-transition-name';

class MetaComponent extends Component {
  get hasIfArgument() {
    return ('if' in this.args);
  }

  get hasValueArgument() {
    return ('value' in this.args);
  }

  get shouldRender() {
    if (this.hasIfArgument) return !!this.args['if'];
    if (this.hasValueArgument) return !!this.args.value;
    return true;
  }

  <template>
    {{#if this.shouldRender}}
      <div class="item">
        <div class="label">{{@label}}</div>
        <div>
          {{#if (has-block)}}
            {{yield}}
          {{else}}
            {{@value}}
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}

<template>
  <div class="detail-header" {{viewTransitionName 'page-header'}}>
    <div class="top">
      <div class="left">
        {{#if (has-block 'title')}}
          <h1 class="title">
            {{yield to="title"}}
          </h1>
        {{/if}}

        {{#if (has-block 'description')}}
          <p class="description">
            {{yield to="description"}}
          </p>
        {{/if}}
      </div>

      {{#if (has-block 'actions')}}
        <div class="actions">
          {{yield to="actions"}}
        </div>
      {{/if}}
    </div>

    {{#if (has-block 'meta')}}
      <div class="meta">
        {{yield MetaComponent to="meta"}}
      </div>
    {{/if}}
  </div>
</template>
