import Service from '@ember/service';
import DeferredPromise from 'frontend/utils/deferred-promise';
import { tracked } from '@glimmer/tracking';
import { AlertModalComponent, ConfirmModalComponent } from 'frontend/components/layout/modal-service-dialog';

export class ModalDialog {
  promise = null;

  constructor() {
    this.promise = new DeferredPromise();
  }

  resolve = (value) => {
    this.promise.resolve(value);
  }

  reject = (error) => {
    this.promise.reject(error);
  }
}

export class AlertModal extends ModalDialog {
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

export class ConfirmModal extends ModalDialog {
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
    const modalDialog = new AlertModal({ title, text });
    const componentClass = AlertModalComponent;
    return await this.execute(modalDialog, componentClass);
  }

  async confirm(text, { title, yesTitle, noTitle } = {}) {
    const modalDialog = new ConfirmModal({ title, text, yesTitle, noTitle });
    const componentClass = ConfirmModalComponent;
    return await this.execute(modalDialog, componentClass);
  }

  async execute(modalDialog, componentClass) {
    this.current = { modalDialog, componentClass };
    const result = await this.current.modalDialog.promise;
    this.current = null;
    return result;
  }
}
