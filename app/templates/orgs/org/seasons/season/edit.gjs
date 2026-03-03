import { pageTitle } from 'ember-page-title';
import SeasonEditPage from 'frontend/components/pages/seasons/edit';

<template>
  {{pageTitle "Edit"}}
  <SeasonEditPage
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
