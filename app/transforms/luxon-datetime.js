import Transform from '@ember-data/serializer/transform';
import { DateTime } from 'luxon';

export default class LuxonDateTimeTransform extends Transform {
  deserialize(serialized) {
    if (!serialized) return null;
    return DateTime.fromISO(serialized, { zone: 'utc' });
  }

  serialize(deserialized) {
    if (!deserialized) return null;
    if (deserialized instanceof DateTime) return deserialized.toUTC().toISO();
    return deserialized;
  }
}
