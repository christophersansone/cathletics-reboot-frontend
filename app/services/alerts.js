import Service from '@ember/service';
import { TrackedArray } from 'tracked-built-ins';
import { action } from '@ember/object';

const DEFAULT_TIMEOUT = 7000;

let nextId = 0;

export default class AlertsService extends Service {
  items = new TrackedArray([]);

  add(variant, message, { timeout = DEFAULT_TIMEOUT } = {}) {
    const alert = { id: nextId++, variant, message, timeout };
    this.items.push(alert);
    return alert;
  }

  @action
  dismiss(alert) {
    const index = this.items.indexOf(alert);
    if (index > -1) {
      this.items.splice(index, 1);
    }
  }

  success(message, options) { return this.add('success', message, options); }
  info(message, options) { return this.add('info', message, options); }
  warning(message, options) { return this.add('warning', message, options); }
  danger(message, options) { return this.add('danger', message, options); }
  error(message, options) { return this.add('danger', message, options); }
  primary(message, options) { return this.add('primary', message, options); }
}
