import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle @model.name}}
  {{outlet}}
</template>
