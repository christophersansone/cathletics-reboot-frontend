import { pageTitle } from 'ember-page-title';
import SettingsPage from 'frontend/components/pages/settings';

<template>
  {{pageTitle "Settings"}}
  <SettingsPage @org={{@model.org}} />
</template>
