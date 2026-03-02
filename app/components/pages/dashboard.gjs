import UiCard from 'frontend/components/ui/card';
import InfiniteScrollTest from 'frontend/components/infinite-scroll-test';

<template>
  <div class="page-header">
    <h1 class="page-header__title">Dashboard</h1>
    <p class="page-header__description">Overview of your organization's activities</p>
  </div>

  <div class="dashboard-grid">
    <UiCard @title="Active Seasons">
      <div class="stat-value">—</div>
      <div class="stat-label">Seasons currently running</div>
    </UiCard>

    <UiCard @title="Open Registration">
      <div class="stat-value">—</div>
      <div class="stat-label">Leagues accepting signups</div>
    </UiCard>

    <UiCard @title="Total Members">
      <div class="stat-value">—</div>
      <div class="stat-label">Registered in your organization</div>
    </UiCard>

    <UiCard @title="Teams">
      <div class="stat-value">—</div>
      <div class="stat-label">Active teams this season</div>
    </UiCard>
  </div>
  <InfiniteScrollTest />
</template>
