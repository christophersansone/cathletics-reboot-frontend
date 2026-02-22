import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

const STORAGE_KEY = 'cathletics:theme';

export default class ThemeService extends Service {
  @tracked current = 'light';

  constructor() {
    super(...arguments);
    this.restore();
  }

  restore() {
    let stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      this.current = stored;
    } else {
      let prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      this.current = prefersDark ? 'dark' : 'light';
    }
    this.apply();
  }

  toggle() {
    this.current = this.current === 'light' ? 'dark' : 'light';
    localStorage.setItem(STORAGE_KEY, this.current);
    this.apply();
  }

  apply() {
    document.documentElement.setAttribute('data-theme', this.current);
  }

  get isDark() {
    return this.current === 'dark';
  }
}
