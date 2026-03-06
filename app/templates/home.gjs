import { pageTitle } from 'ember-page-title';
import HomePage from 'frontend/components/pages/home';

<template>
  {{pageTitle "Home"}}
  <HomePage
    @activeRegistrations={{@model.activeRegistrations}}
    @openLeagues={{@model.openLeagues}}
  />
</template>
