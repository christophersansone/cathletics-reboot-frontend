import { pageTitle } from 'ember-page-title';
import MyFamilyShowPage from 'frontend/components/pages/my-family/show';

<template>
  {{pageTitle @model.name}}
  <MyFamilyShowPage @family={{@model}} />
</template>
