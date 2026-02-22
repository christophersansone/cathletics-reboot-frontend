import { pageTitle } from 'ember-page-title';
import ActivityTypesPage from 'frontend/components/pages/activity-types';

<template>
  {{pageTitle "Activities"}}
  <ActivityTypesPage>
    {{outlet}}
  </ActivityTypesPage>
</template>
