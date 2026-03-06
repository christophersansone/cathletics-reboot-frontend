import { pageTitle } from 'ember-page-title';
import AlertToasts from 'frontend/components/layout/alert-toasts';
import ModalServiceDialog from 'frontend/components/layout/modal-service-dialog';
import MemberShell from 'frontend/components/member-shell';
import routerViewTransition from 'frontend/modifiers/router-view-transition';

<template>
  {{pageTitle "Cathletics"}}
  <AlertToasts />
  <ModalServiceDialog />

  {{#if @controller.isMemberRoute}}
    <MemberShell>
      <div id="app" {{routerViewTransition}}>
        {{outlet}}
      </div>
    </MemberShell>
  {{else}}
    <div id="app" {{routerViewTransition}}>
      {{outlet}}
    </div>
  {{/if}}
</template>
