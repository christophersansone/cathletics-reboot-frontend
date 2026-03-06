import { pageTitle } from 'ember-page-title';
import MyFamilyIndexPage from 'frontend/components/pages/my-family/index';

<template>
  {{pageTitle "My Family"}}
  <MyFamilyIndexPage @families={{@model}} />
</template>
