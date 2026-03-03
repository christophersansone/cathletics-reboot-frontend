import LeagueShowPage from 'frontend/components/pages/leagues/show';

<template>
  <LeagueShowPage
    @league={{@model.league}}
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
