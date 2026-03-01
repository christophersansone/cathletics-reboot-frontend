import Component from '@glimmer/component';
import { eq } from 'ember-truth-helpers';
import args from 'frontend/decorators/args';
import AdapterError from '@ember-data/adapter/error';
import Alert from './ui/alert';

const STATUS_MESSAGES = {
  '404': 'The requested information could not be found.',
  '401': 'You are not authenticated to perform this action.',
  '403': 'You are not authorized to perform this action.',
  '429': 'You have attempted too many requests. Please try again in a few minutes.',
  '500': 'The server could not respond to this request.',
};

@args({
  error: { required: true },
})
export default class ModelErrors extends Component {
  get errorMessages() {
    if (this.args.error instanceof AdapterError) {
      return this.adapterErrorMessages(this.args.error);
    }

    if (this.args.error) {
      return [ this.errorMessageFromStatus(this.args.error) ];
    }

    return [];
  }

  errorMessageFromStatus(error) {
    const status = (error.status || '').toString();
    return STATUS_MESSAGES[status] ?? `The server returned an error status of ${status}.`;
  }

  adapterErrorMessages(error) {
    const errors = error.errors || [];
    if (errors.length > 0) {
      return errors.map((e) => e.detail ?? e.title ?? e );
    }

    return [ error.message ?? 'The server returned an error to the request.' ];
  };


  <template>
    {{#if this.errorMessages}}
      <Alert @variant="danger" ...attributes>
        <ul class="{{if (eq this.errorMessages.length 1) 'single' 'multiple'}}">
          {{#each this.errorMessages as |error|}}
            <li>{{error}}</li>
          {{/each}}
        </ul>
      </Alert>
    {{/if}}
  </template>
}
