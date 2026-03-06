import { pageTitle } from 'ember-page-title';
import TeamViewPage from 'frontend/components/pages/team-view';

<template>
  {{pageTitle @model.name}}
  <TeamViewPage @team={{@model}}>
    {{outlet}}
  </TeamViewPage>
</template>
