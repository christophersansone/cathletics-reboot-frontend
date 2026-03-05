import { pageTitle } from 'ember-page-title';
import DashboardPage from 'frontend/components/pages/dashboard';

<template>
  {{pageTitle "Dashboard"}}
  <DashboardPage @stats={{@model.stats}} @org={{@model.org}} />
</template>
