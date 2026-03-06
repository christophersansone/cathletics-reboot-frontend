import { pageTitle } from 'ember-page-title';
import AlertToasts from 'frontend/components/layout/alert-toasts';
import ModalServiceDialog from 'frontend/components/layout/modal-service-dialog';
  import routerViewTransition from 'frontend/modifiers/router-view-transition';

<template>
  {{pageTitle "Cathletics"}}
  <AlertToasts />
  <ModalServiceDialog />

  <div id="app" {{routerViewTransition}}>
    {{outlet}}
  </div>
</template>
