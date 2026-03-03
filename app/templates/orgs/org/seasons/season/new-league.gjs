import { pageTitle } from 'ember-page-title';
import LeaguesNewPage from 'frontend/components/pages/leagues/new';

<template>
  {{pageTitle "New League"}}
  <LeaguesNewPage
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
