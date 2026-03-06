import Component from '@glimmer/component';
import { tracked, cached, action, service, on, fn, eq, Errors, Await } from 'frontend/utils/stdlib';
import { task, timeout } from 'ember-concurrency';
import { UiButton, UiCard, UiInput, UiSelect, UiGradeLevelSelect, UiModal } from 'frontend/components/ui';
import { ModalDialog } from 'frontend/services/modal';
import FamilyMemberList from 'frontend/components/family/member-list';
import autoFocus from 'frontend/modifiers/auto-focus';
import preventDefault from 'frontend/helpers/prevent-default';

class ChildModal extends ModalDialog {
  store = null;
  atomic = null;
  @tracked firstName = '';
  @tracked lastName = '';
  @tracked dateOfBirth = '';
  @tracked gradeLevel = '';
  @tracked gender = '';

  title = 'Add Child';

  constructor(attrs = {}) {
    super();
    this.store = attrs.store;
    this.atomic = attrs.atomic;
    if (attrs.firstName) this.firstName = attrs.firstName;
    if (attrs.lastName) this.lastName = attrs.lastName;
    if (attrs.dateOfBirth) this.dateOfBirth = attrs.dateOfBirth;
    if (attrs.gradeLevel != null) this.gradeLevel = String(attrs.gradeLevel);
    if (attrs.gender) this.gender = attrs.gender;
  }

  get childAttrs() {
    return {
      firstName: this.firstName,
      lastName: this.lastName,
      dateOfBirth: this.dateOfBirth || null,
      gradeLevel: this.gradeLevel ? Number(this.gradeLevel) : null,
      gender: this.gender || null,
    };
  }

  saveTask = task({ drop: true }, async () => {
    throw new Error('Not implemented');
  });

  get isSaving() { return this.saveTask.isRunning; }

  @action save() { this.saveTask.perform(); }
  @action cancel() { this.promise.resolve({ result: 'canceled' }); }
  @action updateField(field, event) { this[field] = event.target.value; }
}

class AddChildModal extends ChildModal {
  title = 'Add Child';
  family = null;

  constructor(attrs) {
    super(attrs);
    this.family = attrs.family;
  }

  saveTask = task({ drop: true }, async () => {
    const adapter = this.store.adapterFor('family');
    const child = await adapter.createChild(this.family, this.childAttrs);
    this.promise.resolve({ result: 'saved', model: child });
  });
}

class EditChildModal extends ChildModal {
  title = 'Edit Child';
  child = null;

  constructor(attrs) {
    super(attrs);
    this.child = attrs.child;
  }

  saveTask = task({ drop: true }, async () => {
    await this.atomic.updateModel(this.child, this.childAttrs);
    this.promise.resolve({ result: 'saved', model: this.child });
  });
}

class InviteModal extends ModalDialog {
  title = 'Invite to Family';
  @tracked role = 'parent';
  @tracked generatedLink = null;
  family = null;
  atomic = null;

  constructor(attrs) {
    super();
    this.family = attrs.family;
    this.atomic = attrs.atomic;
  }

  saveTask = task({ drop: true }, async () => {
    const { role, family } = this;
    const invitation = await this.atomic.createModel('family-invitation', { role, family });
    const link = `${window.location.origin}/join-family/${invitation.token}`;
    this.generatedLink = link;
  });

  get isSaving() { return this.saveTask.isRunning; }
  get isGenerated() { return !!this.generatedLink; }

  @action generateLink() { this.saveTask.perform(); }
  @action close() { this.promise.resolve({ result: 'closed' }); }
  @action updateRole(event) { this.role = event.target.value; this.generatedLink = null; }

  copyLink = task({ drop: true }, async () => {
    await navigator.clipboard.writeText(this.generatedLink);
    await timeout(5000);
  });
}

const InviteModalComponent = <template>
  <UiModal @title={{@modalDialog.title}} @onClose={{@modalDialog.close}}>
    <div class="flex flex-col gap-4">
      <Errors @error={{@modalDialog.saveTask.last.error}} />
      <UiSelect
        @label="Role"
        @id="invite-role"
        {{on "change" @modalDialog.updateRole}}
      >
        <option value="parent" selected={{if (eq @modalDialog.role "parent") true}}>Parent / Guardian</option>
        <option value="viewer" selected={{if (eq @modalDialog.role "viewer") true}}>Viewer (read-only)</option>
      </UiSelect>

      {{#if @modalDialog.isGenerated}}
        <div class="invite-link-box">
          <code class="invite-link-text">{{@modalDialog.generatedLink}}</code>
          <UiButton @size="sm" @variant={{if @modalDialog.copyLink.isRunning 'success' 'secondary'}} {{on "click" @modalDialog.copyLink.perform}}>
            {{if  @modalDialog.copyLink.isRunning 'Copied' 'Copy'}}
          </UiButton>
        </div>
        <p class="text-secondary text-sm">
          Share this link with the person you want to invite. They'll need a Cathletics account to accept.
        </p>
      {{/if}}

      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @modalDialog.close}}>
          {{if @modalDialog.isGenerated "Done" "Cancel"}}
        </UiButton>
        {{#unless @modalDialog.isGenerated}}
          <UiButton @loading={{@modalDialog.isSaving}} disabled={{@modalDialog.isSaving}} {{on "click" @modalDialog.generateLink}}>
            Generate Link
          </UiButton>
        {{/unless}}
      </div>
    </div>
  </UiModal>
</template>;

const ChildModalComponent = <template>
  <UiModal @title={{@modalDialog.title}} @onClose={{@modalDialog.cancel}}>
    <Errors @error={{@modalDialog.saveTask.last.error}} />
    <form class="flex flex-col gap-4" {{on "submit" (preventDefault @modalDialog.save)}}>
      <div class="form-row">
        <UiInput
          @label="First Name"
          @value={{@modalDialog.firstName}}
          @placeholder="First name"
          @id="child-first-name"
          {{on "input" (fn @modalDialog.updateField "firstName")}}
          {{autoFocus}}
        />
        <UiInput
          @label="Last Name"
          @value={{@modalDialog.lastName}}
          @placeholder="Last name"
          @id="child-last-name"
          {{on "input" (fn @modalDialog.updateField "lastName")}}
        />
      </div>

      <UiInput
        @label="Date of Birth"
        @type="date"
        @value={{@modalDialog.dateOfBirth}}
        @id="child-dob"
        {{on "input" (fn @modalDialog.updateField "dateOfBirth")}}
      />

      <UiGradeLevelSelect
        @label="Grade Level"
        @id="child-grade"
        @value={{@modalDialog.gradeLevel}}
        {{on "change" (fn @modalDialog.updateField "gradeLevel")}}
      />

      <UiSelect
        @label="Gender"
        @id="child-gender"
        @placeholder="Select gender..."
        {{on "change" (fn @modalDialog.updateField "gender")}}
      >
        <option value="male" selected={{if (eq @modalDialog.gender "male") true}}>Male</option>
        <option value="female" selected={{if (eq @modalDialog.gender "female") true}}>Female</option>
      </UiSelect>

      <div class="flex gap-3 justify-end">
        <UiButton @variant="secondary" {{on "click" @modalDialog.cancel}}>Cancel</UiButton>
        <UiButton @type="submit" @loading={{@modalDialog.isSaving}} disabled={{@modalDialog.isSaving}}>
          Save
        </UiButton>
      </div>
    </form>
  </UiModal>
</template>;

export default class MyFamilyShowPage extends Component {
  @service store;
  @service session;
  @service atomic;
  @service alerts;
  @service modal;
  @service pagination;

  get family() {
    return this.args.family;
  }

  @cached
  get membershipsPaginator() {
    return this.pagination.hasMany(this.family, 'familyMemberships');
  }

  @cached
  get invitationsPaginator() {
    return this.pagination.hasMany(this.family, 'familyInvitations');
  }

  get canManage() {
    const currentUserId = this.session.currentUser.id;
    const membership = this.membershipsPaginator.displayItems.find((m) => m.belongsTo('user').id() === currentUserId);
    return membership?.canManage;
  }

  renameFamilyTask = task({ drop: true }, async () => {
    const newName = await this.modal.prompt?.('Rename family') || null;
    if (!newName) return;
    await this.atomic.updateModel(this.family, { name: newName });
    this.alerts.success('Family renamed.');
  });

  addChild = task({ drop: true }, async () => {
    const dialog = new AddChildModal({
      store: this.store,
      family: this.family,
      lastName: this.session.currentUser.lastName,
    });
    const result = await this.modal.execute(dialog, ChildModalComponent);
    if (result.result === 'saved') {
      this.alerts.success('Child added!');
      await this.membershipsPaginator.reload();
    }
  });

  editChild = task({ drop: true }, async (membership) => {
    const child = await membership.user;
    const dialog = new EditChildModal({
      store: this.store,
      atomic: this.atomic,
      child,
      firstName: child.firstName,
      lastName: child.lastName,
      dateOfBirth: child.dateOfBirth,
      gradeLevel: child.gradeLevel,
      gender: child.gender,
    });
    const result = await this.modal.execute(dialog, ChildModalComponent);
    if (result.result === 'saved') {
      this.alerts.success('Child updated.');
    }
  });

  createInvite = task({ drop: true }, async () => {
    const dialog = new InviteModal({
      family: this.family,
      atomic: this.atomic,
    });
    await this.modal.execute(dialog, InviteModalComponent);
    await this.invitationsPaginator.reload();
  });

  revokeInvite = task(async (invitation) => {
    const confirmed = await this.modal.confirm('Revoke this invite link? It will no longer work.');
    if (!confirmed) return;
    await this.atomic.destroyModel(invitation);
    this.alerts.success('Invite revoked.');
    await this.invitationsPaginator.reload();
  });

  removeChild = task(async (membership) => {
    const child = await membership.user;
    const name = child?.fullName || 'this child';
    const confirmed = await this.modal.confirm(`Remove ${name} from your family?`);
    if (!confirmed) return;
    await this.atomic.destroyModel(membership);
    this.alerts.success('Child removed.');
    await this.membershipsPaginator.reload();
  });

  <template>
    <div class="member-page">
        <UiCard @title={{this.family.name}}>
          <Errors @error={{this.renameFamilyTask.last.error}} />
          <Errors @error={{this.removeChild.last.error}} />
          <FamilyMemberList
            @paginator={{this.membershipsPaginator}}
            @onAddChild={{if this.canManage this.addChild.perform}}
            @onEditChild={{if this.canManage this.editChild.perform}}
            @onRemoveChild={{if this.canManage this.removeChild.perform}}
          />
        </UiCard>

        {{#if this.canManage}}
          <UiCard @title="Invite Links">
            <:actions>
              <UiButton @size="sm" {{on "click" this.createInvite.perform}}>Create Invite</UiButton>
            </:actions>
            <:default>
              <Await @promise={{this.invitationsPaginator.firstPage}} @showLatest={{true}}>
                {{#if this.invitationsPaginator.displayItems.length}}
                  <Errors @error={{this.revokeInvite.last.error}} />
                  <ul class="member-list">
                    {{#each this.invitationsPaginator.displayItems as |invitation|}}
                      <li class="member-list__item">
                        <div class="flex-1">
                          <span class="font-medium invite-role-label">{{invitation.role}}</span>
                          <span class="text-secondary text-sm">
                            Created
                            <Await @promise={{invitation.createdBy}} as |user|>
                              by {{user.fullName}}
                            </Await>
                          </span>
                        </div>
                        <UiButton @variant="ghost" @size="sm" class="text-danger" {{on "click" (fn this.revokeInvite.perform invitation)}}>
                          Revoke
                        </UiButton>
                      </li>
                    {{/each}}
                  </ul>
                {{else}}
                  <p class="text-secondary text-sm">No active invite links. Create one to invite family members as parents and organizers, or view mode for extended family such as grandparents.</p>
                {{/if}}
              </Await>
            </:default>
          </UiCard>
        {{/if}}
    </div>
  </template>
}
