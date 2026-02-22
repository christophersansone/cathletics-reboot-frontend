import Model, { attr, belongsTo, hasMany } from '@ember-data/model';

export default class ActivityTypeModel extends Model {
  @attr('string') name;
  @attr('string') description;

  @belongsTo('organization', { async: true, inverse: 'activityTypes' }) organization;
  @hasMany('season', { async: true, inverse: 'activityType' }) seasons;
}
