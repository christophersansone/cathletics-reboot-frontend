/*

  A DeferredPromise simply exposes resolve() and reject() externally.
  Occasionally this can be useful, for example when waiting for a modal dialog to be closed.

  With this class, you can either pass in a standard resolver method,
  just like you would with a normal Promise, where the promise can be resolved or rejected
  both internally and externally, for example:

  const deferred = new DeferredPromise((resolve, reject) => {
    window.setTimeout(resolve, 1000);
  });
  window.setTimeout(deferred.reject, 500);

  OR you can not pass in a function and simply resolve it externally, for example:

  const deferred = new DeferredPromise();
  ...
  deferred.resolve();
*/

export default class DeferredPromise extends Promise {
  constructor(fn) {
    let resolver, rejecter;

    super(function (resolve, reject) {
      resolver = resolve;
      rejecter = reject;
    });

    this.resolve = resolver;
    this.reject = rejecter;

    if (fn) {
      fn(this.resolve, this.reject);
    }
  }
}
