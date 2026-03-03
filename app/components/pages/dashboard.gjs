import UiCard from 'frontend/components/ui/card';
import PageHeader from 'frontend/components/layout/page-header';

<template>
  <PageHeader>
    <:title>Dashboard</:title>
    <:description>Overview of your organization's activities</:description>
  </PageHeader>

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
</template>
