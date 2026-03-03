import viewTransitionName from 'frontend/modifiers/view-transition-name';

<template>
  <div class="page-header flex items-center justify-between" {{viewTransitionName 'page-header'}}>
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
</template>
