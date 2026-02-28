import Component from '@glimmer/component';
import { task, Task, TaskInstance } from 'ember-concurrency';
import { tracked, cached } from '@glimmer/tracking';
import args from 'frontend/decorators/args';
import LoadingIndicator from './ui/loading-indicator';
import Errors from './errors';
import { hash } from '@ember/helper';

/* Arguments:
   @promise -- A promise to await. Can also be an Ember Concurrency Task or TaskInstance.
   @showLatest -- If true, the component will always display the latest value while reloading,
    as opposed to transitioning back to the loading state. Defaults to false.

  Note: Typical Javascript promises do not have an API to determine state synchronously.
  The only way to determine state is to wrap it in another promise and await completion,
  which is not synchronous.  Therefore, if the promise is already completed, this component
  cannot know until the next event loop.  In general, this is not a huge deal, but it is worth
  noting.  To minimize this issue, this component has special handling for Ember Concurrency
  tasks and task instances, which do have a synchronous API for determining state.
*/

@args({
  promise: { required: true },
  showLatest: { type: 'boolean' },
})
export default class AwaitComponent extends Component {

  @cached
  get taskInstance() {
    const promise = this.args.promise;
    let result = null;
    if (promise instanceof TaskInstance) {
      result = promise;
    } else if (promise instanceof Task) {
      result = promise.last;
    } else if (promise) {
      result = this.promiseTask.perform(promise);
    }

    this.lastTaskInstance = this._currentTaskInstance;
    this._currentTaskInstance = result;

    return result;
  }

  @tracked lastTaskInstance = null;

  promiseTask = task({ restartable: true }, async (promise) => {
    return await promise;
  });

  get value() {
    if (this.taskInstance?.isSuccessful) {
      return this.taskInstance.value;
    } else if (this.isPending) {
      return this.lastTaskInstance?.value;
    } else {
      return null;
    }
  }

  get isPending() {
    return this.taskInstance?.hasStarted && !this.taskInstance?.isFinished;
  }

  get isRejected() {
    return this.taskInstance?.isError;
  }

  get isSuccessful() {
    return this.taskInstance?.isSuccessful;
  }

  get error() {
    if (this.taskInstance?.isError) {
      let result = this.taskInstance.error;
      if (typeof result === 'string') {
        result = new Error(result);
      }
      return result;
    } else {
      return null;
    }
  }

  get showLoading() {
    if (!this.isPending) {
      return false;
    }

    if (this.value) {
      return !this.args.showLatest;
    }

    return true;
  }

  <template>
  {{#if this.taskInstance}}
    {{#if (has-block 'state')}}
      {{yield (hash
        isPending=this.isPending
        isSuccessful=this.isSuccessful
        isRejected=this.isRejected
        value=this.value
        error=this.error
      ) to="state"}}

    {{else}}

      {{#if this.showLoading}}
        {{#if (has-block 'pending')}}
          {{yield to='pending'}}
        {{else}}
          <LoadingIndicator />
        {{/if}}
      {{else if this.isRejected}}
        {{#if (has-block 'rejected')}}
          {{yield this.error to='rejected'}}
        {{else}}
          <Errors @error={{this.error}} />
        {{/if}}
      {{else}}
        {{yield this.value}}
        {{yield this.value to="resolved"}}
        {{yield this.value to="success"}}
      {{/if}}
    {{/if}}
  {{/if}}
</template>
}
