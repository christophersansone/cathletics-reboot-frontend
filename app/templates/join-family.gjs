import { pageTitle } from 'ember-page-title';
import JoinFamilyPage from 'frontend/components/pages/join-family';

<template>
  {{pageTitle "Join Family"}}
  <JoinFamilyPage @invitation={{@model}} />
</template>
