// app/services/cache.js
import Service from '@ember/service';
import { TrackedObject } from 'tracked-built-ins';

// Usage: this.cache.get() / this.cache.set() / this.cache.keys.someKey
export default class CacheService extends Service {
  #store = new TrackedObject({}); // key -> { value, expiresAt }
  keys = null;

  constructor() {
    super(...arguments);

    this.keys = new Proxy(
      {},
      {
        get: (_, prop) => this.#read(prop),

        set: (_, prop, value) => {
          // eslint-disable-next-line ember/classic-decorator-no-classic-methods
          this.set(prop, value);
          return true;
        },

        deleteProperty: (_, prop) => {
          this.delete(prop);
          return true;
        },

        has: (_, prop) => this.has(prop),

        ownKeys: () => {
          this.#sweepAllExpired();
          return Reflect.ownKeys(this.#store);
        },

        getOwnPropertyDescriptor: (_, prop) => {
          if (this.has(prop)) {
            return {
              enumerable: true,
              configurable: true
            };
          }
        }
      }
    );
  }

  #read(key) {
    let entry = this.#store[key];
    if (!entry) return undefined;

    if (entry.expiresAt && entry.expiresAt <= Date.now()) {
      delete this.#store[key];
      return undefined;
    }

    return entry.value;
  }

  set(key, value, ttlMs = null) {
    let expiresAt = ttlMs != null ? Date.now() + ttlMs : null;

    this.#store[key] = { value, expiresAt };

    this.#maybeSweep();
  }

  get(key) {
    return this.#read(key);
  }

  delete(key) {
    delete this.#store[key];
  }

  has(key) {
    return this.#read(key) !== undefined;
  }

  clear() {
    for (let key of Object.keys(this.#store)) {
      delete this.#store[key];
    }
  }

  #maybeSweep() {
    let keys = Object.keys(this.#store);
    if (keys.length < 50) return;

    let now = Date.now();

    for (let i = 0; i < Math.min(keys.length, 20); i++) {
      let key = keys[i];
      let entry = this.#store[key];

      if (entry?.expiresAt && entry.expiresAt <= now) {
        delete this.#store[key];
      }
    }
  }

  #sweepAllExpired() {
    let now = Date.now();

    for (let key of Object.keys(this.#store)) {
      let entry = this.#store[key];
      if (entry?.expiresAt && entry.expiresAt <= now) {
        delete this.#store[key];
      }
    }
  }
}
