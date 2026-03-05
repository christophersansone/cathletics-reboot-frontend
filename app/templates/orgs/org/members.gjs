import { pageTitle } from 'ember-page-title';
import MembersPage from 'frontend/components/pages/members';

<template>
  {{pageTitle "Members"}}
  <MembersPage @org={{@model.org}} />
</template>
