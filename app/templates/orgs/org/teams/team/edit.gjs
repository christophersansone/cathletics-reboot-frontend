import { pageTitle } from 'ember-page-title';
import TeamEditPage from 'frontend/components/pages/teams/edit';

<template>
  {{pageTitle "Edit"}}
  <TeamEditPage
    @team={{@model.team}}
    @league={{@model.league}}
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
