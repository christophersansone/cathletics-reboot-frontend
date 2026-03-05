import { Errors, on, action, tracked } from 'frontend/utils/stdlib';
import { UiModal, UiButton, UiInput } from 'frontend/components/ui';
import autoFocus from 'frontend/modifiers/auto-focus';
import { ModalDialog } from 'frontend/services/modal';
import { task } from 'ember-concurrency';
import preventDefault from 'frontend/helpers/prevent-default';

class TeamModal extends ModalDialog {
  atomic = null;
  @tracked name = '';

  constructor({ atomic }) {
    super();
    this.atomic = atomic;
  }

  saveTask = task({ drop: true }, async () => {
    throw new Error('Not implemented');
  });

  get isSaving() { return this.saveTask.isRunning; }

  @action save() { this.saveTask.perform(); }
  @action cancel() { this.promise.resolve({ result: 'canceled' }); }

  @action
  updateName(event) { this.name = event.target.value; }
}

export class CreateTeamModal extends TeamModal {
  league = null;
  title = 'New Team';

  constructor({ league, atomic }) {
    super({ atomic });
    this.league = league;
  }

  saveTask = task({ drop: true }, async () => {
    const model = await this.atomic.createModel('team', { name: this.name, league: this.league });
    this.promise.resolve({ result: 'saved', model });
  });
}

export class EditTeamModal extends TeamModal {
  model = null;
  title = 'Edit Team';

  constructor({ model, atomic }) {
    super({ atomic });
    this.model = model;
    this.name = model.name;
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.model, { name: this.name });
    this.promise.resolve({ result: 'saved', model: this.model });
  });
}

<template>
  <UiModal @title={{@modalDialog.title}} @onClose={{@modalDialog.cancel}}>
    <Errors @error={{@modalDialog.saveTask.last.error}} />
    <form class="flex flex-col gap-4" {{on "submit" (preventDefault @modalDialog.save)}}>
      <UiInput
        @label="Team Name"
        @value={{@modalDialog.name}}
        @placeholder="e.g. Team A, Blue Team"
        @id="team-name"
        {{on "input" @modalDialog.updateName}}
        {{autoFocus}}
      />
      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
        <UiButton @type="submit" @loading={{@modalDialog.isSaving}} disabled={{@modalDialog.isSaving}}>
          Save
        </UiButton>
      </div>
    </form>
  </UiModal>
</template>
