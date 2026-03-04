import TeamShowPage from 'frontend/components/pages/teams/show';

<template>
  <TeamShowPage
    @team={{@model.team}}
    @league={{@model.league}}
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
