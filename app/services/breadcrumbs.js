// app/services/breadcrumbs.js
import Service, { inject as service } from '@ember/service';
import { getOwner } from '@ember/application';
import { task } from 'ember-concurrency';
import { cached } from '@glimmer/tracking';

export default class BreadcrumbsService extends Service {
  @service router;

  @cached
  get segments() {
    return this.segmentsTask.perform(this.router.currentRoute);
  }

  breadcrumbFor(routeInstance, model) {
    if (typeof routeInstance.breadcrumb === 'function') {
      return routeInstance.breadcrumb(model);
    } else {
      return routeInstance.breadcrumb;
    }
  }

  async breadcrumbParentsFor(routeInstance, model) {
    const fn = routeInstance.breadcrumbParents;
    if (!fn) return;

    const breadcrumbParents = await routeInstance.breadcrumbParents(model);
    if (breadcrumbParents) {
      return breadcrumbParents.map((p) => {
        const routeInstance = this.routeInstanceFor(p.route);
        const model = Array.isArray(p.model) ? p.model[p.model.length-1] : p.model;
        const breadcrumb = this.breadcrumbFor(routeInstance, model);
        if (breadcrumb) {
          return { name: p.route, title: breadcrumb.title, models: p.model, isActive: false };
        }
      }).filter((b) => !!b)
    }
  }

  routeInstanceFor(routeName) {
    return getOwner(this).lookup(`route:${routeName}`);
  }

  segmentsTask = task({ restartable: true }, async () => {
    const routes = [];

    let routeInfo = this.router.currentRoute;
    while (routeInfo) {
      routes.unshift(routeInfo);
      routeInfo = routeInfo.parent;
    }
    if (!routes.length) return [];

    const segments = [];
    const cumulativeModels = [];

    for (const info of routes) {
      const { name, attributes, paramNames } = info;

      // ignore the application route and index routes (because their parents control the breadcrumbs)
      if ((name === 'application') || (name.split('.').pop() === 'index')) continue;

      // Add models for this specific segment to the list
      if (paramNames.length > 0 && attributes) {
        cumulativeModels.push(attributes);
      }

      // Look up the actual Route class instance for our custom metadata
      const routeInstance = this.routeInstanceFor(name);
      if (!routeInstance?.breadcrumb) {
        segments.push(null);
        continue;
      }

      const breadcrumbParents = await this.breadcrumbParentsFor(routeInstance, attributes);
      if (breadcrumbParents) {
        segments.push(...breadcrumbParents);
      }

      const breadcrumb = this.breadcrumbFor(routeInstance, attributes);
      if (breadcrumb) {
        const title = breadcrumb.title;
        const models = [...cumulativeModels];
        const isActive = info === this.router.currentRoute;

        segments.push({ name, title, models, isActive });
      }
    }

    return segments.slice(0, -1).filter((s) => !!s);
  })
}
