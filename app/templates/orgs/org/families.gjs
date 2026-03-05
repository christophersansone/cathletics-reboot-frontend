import { pageTitle } from 'ember-page-title';
import FamiliesPage from 'frontend/components/pages/families';

<template>
  {{pageTitle "Families"}}
  <FamiliesPage @org={{@model.org}} />
</template>
