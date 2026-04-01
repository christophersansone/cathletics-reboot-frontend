import Component from '@glimmer/component';
import { tracked, args, service, on, action, fn, cached } from 'frontend/utils/stdlib';
import { task } from 'ember-concurrency';
import { DateTime } from 'luxon';
import { UiCard, UiButton } from 'frontend/components/ui';
import { Await, Errors } from 'frontend/utils/stdlib';
import FormattedTime from 'frontend/components/formatted-time';
import { parseIcalToOccurrences } from 'frontend/utils/parse-ical-occurrences';
import { recursUntilDateBeforeOccurrence } from 'frontend/utils/recurrence-truncate';
import ScheduledEventModalComponent, { CreateScheduledEventModal, EditScheduledEventModal } from 'frontend/components/scheduled-event/modal';
import OccurrenceIntentModalComponent, { OccurrenceIntentModal } from 'frontend/components/team/occurrence-intent-modal';
import CancelReasonModalComponent, { CancelReasonModal } from 'frontend/components/team/cancel-reason-modal';

@args({
  team: { required: true },
  canManageSchedule: { type: 'boolean', allowNull: true },
})
export default class ScheduleTab extends Component {
  @service session;
  @service atomic;
  @service cache;
  @service modal;
  @service alerts;
  @service store;

  @tracked occurrences = [];
  @tracked from = null;
  @tracked to = null;

  constructor(owner, args) {
    super(owner, args);
    this.setDefaultRange();
  }

  get canManageSchedule() {
    return this.isTeamManager || this.isOrgAdmin;
  }

  @cached
  get isTeamManager() {
    const members = this.cache.get(`team-${this.args.team.id}-associated-members`) ?? [];
    const roles = new Set(['coach', 'assistant_coach', 'manager']);
    return members.some((m) => roles.has(m.role));
  }

  @cached
  get fetchOrganizationRoleTaskInstance() {
    return this.fetchOrganizationRole.perform(this.args.team);
  }

  fetchOrganizationRole = task(async (team) => {
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    const organization = await activityType.organization;
    return await this.session.organizationRoleFor(organization);
  });

  @cached
  get organizationRole() {
    return this.fetchOrganizationRoleTaskInstance.value;
  }

  get isOrgAdmin() {
    return this.organizationRole === 'admin';
  }

  setDefaultRange() {
    const start = DateTime.now().startOf('month');
    const end = start.plus({ months: 2 }).endOf('month');
    this.from = start.toJSDate().toISOString();
    this.to = end.toJSDate().toISOString();
  }

  get occurrencesPromise() {
    return this.loadOccurrencesTask.perform();
  }

  loadOccurrencesTask = task({ drop: true }, async () => {
    const team = this.args.team;
    const adapter = this.store.adapterFor('scheduled-event');
    const icalString = await adapter.occurrences({
      schedulableType: 'Team',
      schedulableId: team.id,
      from: this.from,
      to: this.to,
    });
    const list = parseIcalToOccurrences(icalString);
    this.occurrences = list.map((o) => ({
      ...o,
      startDt: o.startAt ? DateTime.fromISO(o.startAt, { zone: 'utc' }) : null,
    }));
    return this.occurrences;
  });

  get occurrencesWithDt() {
    return this.occurrences;
  }

  createEvent = task({ drop: true }, async () => {
    const team = this.args.team;
    const league = await team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    const org = await activityType.organization;
    const defaultTimeZone = org.timeZone;
    const modalDialog = new CreateScheduledEventModal({
      team,
      atomic: this.atomic,
      defaultTimeZone,
    });
    const result = await this.modal.execute(modalDialog, ScheduledEventModalComponent);
    if (result?.model) {
      this.alerts.success('Event added.');
      await this.loadOccurrencesTask.perform();
    }
  });

  /** @param {{ startAt: string, eventId: string, isRecurring?: boolean }} occ */
  async getScope(occ, actionName) {
    if (!occ.isRecurring) return { scope: 'this_one' };
    const intent = new OccurrenceIntentModal({ action: actionName, occurrence: occ });
    const result = await this.modal.execute(intent, OccurrenceIntentModalComponent);
    return result;
  }

  @action
  async openRemoveOccurrence(occ) {
    const result = await this.getScope(occ, 'remove');
    if (result == null) return;
    const event = await this.store.findRecord('scheduled-event', occ.eventId);
    try {
      if (result.scope === 'this_one') {
        const exdates = [...(event.exdates || []), occ.startAt];
        await this.atomic.updateModel(event, { exdates });
        this.alerts.success('Event removed from schedule.');
      } else {
        const startIso =
          typeof event.startAt === 'string' ? event.startAt : event.startAt?.toISO?.() ?? String(event.startAt);
        const nextUntil = recursUntilDateBeforeOccurrence({
          eventStartAtIso: startIso,
          occurrenceStartAtIso: occ.startAt,
          rrule: event.rrule,
          timeZone: event.timeZone,
        });
        if (nextUntil) {
          await this.atomic.updateModel(event, { recursUntil: nextUntil });
        } else {
          await this.atomic.updateModel(event, { rrule: null, recursUntil: null });
        }
        this.alerts.success('All future occurrences removed.');
      }
      await this.loadOccurrencesTask.perform();
    } catch (e) {
      this.alerts.error(e?.message ?? 'Failed to remove.');
    }
  }

  @action
  async openCancelOccurrence(occ) {
    const result = await this.getScope(occ, 'cancel');
    if (result == null) return;
    const reasonModal = new CancelReasonModal();
    const reasonResult = await this.modal.execute(reasonModal, CancelReasonModalComponent);
    if (reasonResult == null) return;
    const event = await this.store.findRecord('scheduled-event', occ.eventId);
    const reason = reasonResult.reason ?? '';
    try {
      if (result.scope === 'this_one') {
        const existing = (event.cancelledOccurrences || []).map((o) => ({
          start_at: o.start_at ?? o.startAt,
          reason: o.reason ?? '',
        }));
        const cancelledOccurrences = [...existing, { start_at: occ.startAt, reason }];
        await this.atomic.updateModel(event, { cancelledOccurrences });
        this.alerts.success('Occurrence cancelled.');
      } else {
        await this.atomic.updateModel(event, {
          cancelledFrom: occ.startAt,
          cancellationReason: reason,
        });
        this.alerts.success('All future occurrences cancelled.');
      }
      await this.loadOccurrencesTask.perform();
    } catch (e) {
      this.alerts.error(e?.message ?? 'Failed to cancel.');
    }
  }

  @action
  async openEditOccurrence(occ) {
    const result = await this.getScope(occ, 'edit');
    if (result == null) return;
    const event = await this.store.findRecord('scheduled-event', occ.eventId);
    const league = await this.args.team.league;
    const season = await league.season;
    const activityType = await season.activityType;
    const org = await activityType.organization;
    const defaultTimeZone = org.timeZone;
    const modalDialog = new EditScheduledEventModal({
      event,
      occurrence: occ,
      team: this.args.team,
      scope: result.scope,
      atomic: this.atomic,
      defaultTimeZone,
    });
    const modalResult = await this.modal.execute(modalDialog, ScheduledEventModalComponent);
    if (modalResult?.result === 'saved') {
      this.alerts.success(result.scope === 'this_one' ? 'Occurrence updated.' : 'Event updated.');
      await this.loadOccurrencesTask.perform();
    }
  }

  <template>
    <UiCard>
      <div class="header flex flex-wrap gap-2 items-center justify-between">
        <h2 class="title text-lg font-semibold">Schedule</h2>
        {{#if this.canManageSchedule}}
          <UiButton @variant="primary" {{on "click" this.createEvent.perform}}>
            Add event
          </UiButton>
        {{/if}}
      </div>

      <Await @promise={{this.occurrencesPromise}} @showLatest={{true}}>
        <:resolved as |occList|>
          {{#if occList.length}}
            <ul class="list">
              {{#each occList as |occ|}}
                <li class="item {{if occ.cancelled "item-cancelled"}}">
                  <div class="item-main">
                    <span class="item-title">{{occ.title}}</span>
                    <span class="item-time">
                      <FormattedTime @value={{occ.startDt}} @zone={{occ.timeZone}} />
                    </span>
                    {{#if occ.cancelled}}
                      <span class="item-cancelled-label">Cancelled{{#if occ.cancellationReason}} – {{occ.cancellationReason}}{{/if}}</span>
                    {{/if}}
                  </div>
                  {{#if this.canManageSchedule}}
                    <div class="item-actions">
                      <button type="button" class="btn-link text-sm" {{on "click" (fn this.openEditOccurrence occ)}}>Edit</button>
                      {{#unless occ.cancelled}}
                        <button type="button" class="btn-link text-sm" {{on "click" (fn this.openCancelOccurrence occ)}}>Cancel</button>
                      {{/unless}}
                      <button type="button" class="btn-link text-sm text-danger" {{on "click" (fn this.openRemoveOccurrence occ)}}>Remove</button>
                    </div>
                  {{/if}}
                </li>
              {{/each}}
            </ul>
          {{else}}
            <p class="text-secondary text-sm text-center py-8">
              {{#if this.canManageSchedule}}
                No events in this range. Add an event to get started.
              {{else}}
                No events in this range.
              {{/if}}
            </p>
          {{/if}}
        </:resolved>
        <:rejected as |error|>
          <Errors @error={{error}} />
        </:rejected>
      </Await>
    </UiCard>
  </template>
}
