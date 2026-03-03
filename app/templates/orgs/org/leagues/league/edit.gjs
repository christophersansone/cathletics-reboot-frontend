import { pageTitle } from 'ember-page-title';
import LeagueEditPage from 'frontend/components/pages/leagues/edit';

<template>
  {{pageTitle "Edit"}}
  <LeagueEditPage
    @league={{@model.league}}
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
