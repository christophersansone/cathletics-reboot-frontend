import Service from '@ember/service';
import DeferredPromise from 'frontend/utils/deferred-promise';
import { tracked } from '@glimmer/tracking';

class ModalDialog {
  promise = null;

  constructor() {
    this.promise = new DeferredPromise();
  }

  resolve(value) {
    this.promise.resolve(value);
  }

  reject(error) {
    this.promise.reject(error);
  }
}

class AlertModal extends ModalDialog {
  type = 'alert';
  text = null;
  title = null;
  okTitle = null;

  constructor({ text, title = 'Alert', okTitle = 'OK' }) {
    super();
    this.text = text;
    this.title = title;
    this.okTitle = okTitle;
  }
}

class ConfirmModal extends ModalDialog {
  type = 'confirm';
  text = null;
  title = null;
  yesTitle = null;
  noTitle = null;

  constructor({ text, title = 'Confirm', yesTitle = 'Yes', noTitle = 'No' }) {
    super();
    this.text = text;
    this.title = title;
    this.yesTitle = yesTitle;
    this.noTitle = noTitle;
  }
}

export default class ModalService extends Service {
  @tracked current = null;

  async alert(text, { title } = {}) {
    this.current = new AlertModal({ title, text });
    const result = await this.current.promise;
    this.current = null;
    return result;
  }

  async confirm(text, { title, yesTitle, noTitle} = {}) {
    this.current = new ConfirmModal({ title, text, yesTitle, noTitle });
    const result = await this.current.promise;
    this.current = null;
    return result;
  }
}
