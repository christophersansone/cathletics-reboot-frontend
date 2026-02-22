import Model, { attr, belongsTo } from '@ember-data/model';

export default class RegistrationModel extends Model {
  @attr('string') status;

  @belongsTo('league', { async: true, inverse: 'registrations' }) league;
  @belongsTo('user', { async: true, inverse: null }) user;
  @belongsTo('user', { async: true, inverse: null }) registeredBy;
}
