MagicMirror.ApplicationRoute = Ember.Route.extend
  model: ->
    new Ember.RSVP.Promise (resolve, reject) =>
      new Ember.RSVP.hash
        location  : @store.find('location', 1)
        forecasts : @store.findAll('forecast') 
      .then (result) =>
        resolve
          location  : result.location 
          forecasts : result.forecasts