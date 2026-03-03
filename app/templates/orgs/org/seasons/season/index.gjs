import SeasonShowPage from 'frontend/components/pages/seasons/show';

<template>
  <SeasonShowPage
    @season={{@model.season}}
    @activityType={{@model.activityType}}
    @org={{@model.org}}
  />
</template>
