import { pageTitle } from 'ember-page-title';
import AlertToasts from 'frontend/components/layout/alert-toasts';
import ModalServiceDialog from 'frontend/components/layout/modal-service-dialog';

<template>
  {{pageTitle "Cathletics"}}
  <AlertToasts />
  <ModalServiceDialog />
  {{outlet}}
</template>
