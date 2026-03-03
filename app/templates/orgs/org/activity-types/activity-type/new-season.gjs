import { pageTitle } from 'ember-page-title';
import SeasonsNewPage from 'frontend/components/pages/seasons/new';

<template>
  {{pageTitle "New Season"}}
  <SeasonsNewPage @activityType={{@model.activityType}} @org={{@model.org}} />
</template>
