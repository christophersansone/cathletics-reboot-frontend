import { pageTitle } from 'ember-page-title';
import OrgSelectorPage from 'frontend/components/pages/org-selector';

<template>
  {{pageTitle "Select Organization"}}
  <OrgSelectorPage @orgs={{@model}} />
</template>
