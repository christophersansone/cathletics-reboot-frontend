import EmberRouter from '@embroider/router';
import config from 'frontend/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('login');

  this.route('orgs', function () {
    this.route('org', { path: ':org_slug' }, function () {
      this.route('dashboard');
      this.route('activity-types', function () {
        this.route('activity-type', { path: ':activity_type_id' }, function () {
          this.route('new-season');
        });
      });
      this.route('seasons', function () {
        this.route('season', { path: ':season_id' }, function () {
          this.route('edit');
          this.route('new-league');
        });
      });
      this.route('leagues', function () {
        this.route('league', { path: ':league_id' }, function () {
          this.route('edit');
        });
      });
      this.route('teams', function () {
        this.route('team', { path: ':team_id' }, function () {
          this.route('edit');
        });
      });
      this.route('members');
      this.route('families');
      this.route('settings');
    });
  });
});
