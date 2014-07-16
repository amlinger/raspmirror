MagicMirror.Forecast = DS.Model.extend
    dt      : DS.attr 'date'
    temp    : DS.attr 'object'
    weather : DS.attr 'object'

MagicMirror.ForecastAdapter = DS.RESTAdapter.extend
    host    : 'http://api.openweathermap.org/data/2.5'
    service : 'forecast/daily'

    buildURL: (city, country)->
        "#{@host}/#{@service}?q=#{city},#{country}&units=metric&cnt=7"
    
    findAll:(store, type, sinceToken)->
        prepare = (o)->
            # We can consider the datetime to be a unique identifier, since a
            # forecast is only relevant for a specific time.
            # 
            # The datetime passed from the Weather API is given in seconds, so
            # this is converted to milliseconds.
            [ o.id, o.dt, o.weather ] = [ o.dt, o.dt*1000, o.weather[0] ]
            return o

        # It is necessary for the Open Weather Map API to know the location, 
        # so we wait for this promise about our location to resolve before
        # continuing to send our request.
        deferred = new Ember.$.Deferred()    
        store.find('location', 1).then (loc)=>
            url = @buildURL(loc.get('city'), loc.get('abbr'))

            Ember.$.getJSON(url).then (response) =>
                # Using list comprehension all forecast objects are prepared to
                # be inserted into the storage. 
                deferred.resolve({'forecasts' : prepare(x) for x in response.list})
            , (error) =>
                deferred.resolve({'forecasts' : [] })
        deferred.promise()
