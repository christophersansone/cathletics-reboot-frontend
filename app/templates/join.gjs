import { pageTitle } from 'ember-page-title';
import JoinPage from 'frontend/components/pages/join';

<template>
  {{pageTitle "Join Organization"}}
  <JoinPage @org={{@model}} />
</template>
