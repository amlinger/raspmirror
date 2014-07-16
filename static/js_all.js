console.log("HERE");

MagicMirror.ApplicationRoute = Ember.Route.extend({
  model: function() {
    console.log("LOL");
    return new Ember.RSVP.Promise((function(_this) {
      return function(resolve, reject) {
        return new Ember.RSVP.hash({
          forecast: _this.store.findAll('forecast')
        }).then(function(result) {
          console.log("result");
          return resolve({
            forecast: result.forecast
          });
        });
      };
    })(this));
  }
});
