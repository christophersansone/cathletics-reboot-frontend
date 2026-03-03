import Component from '@glimmer/component';
import { formatEventDateTime } from 'frontend/utils/datetime';
import args from 'frontend/decorators/args';

@args({
  value: { required: true },
  zone: { required: true },
})
export default class FormattedTime extends Component {
  get display() {
    return formatEventDateTime(this.args.value, this.args.zone);
  }

  <template>
    {{#if this.display}}
      <span class="formatted-time" ...attributes>
        <span>{{this.display.formatted}}</span>
        {{#unless this.display.sameAsLocal}}
          <span class="formatted-time__zone">{{this.display.zone}}</span>
          <span class="formatted-time__local">({{this.display.localTime}} your time)</span>
        {{/unless}}
      </span>
    {{/if}}
  </template>
}
