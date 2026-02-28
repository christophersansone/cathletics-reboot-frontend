import { pageTitle } from 'ember-page-title';
import AlertToasts from 'frontend/components/alert-toasts';

<template>
  {{pageTitle "Cathletics"}}
  <AlertToasts />
  {{outlet}}
</template>
