import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle @model.team.name}}
  {{outlet}}
</template>
