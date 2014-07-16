MagicMirror.Location = DS.Model.extend
    city    : DS.attr 'string'
    abbr    : DS.attr 'string'
    country : null # Should be a computed attribute.

MagicMirror.LocationController = Ember.ObjectController.extend
    
    time: (->
        #get locale from model. This also means that this will update 
        # every time the location updates.
        console.log @get('model')
        moment().format("hh:mm")
    ).property('model')

MagicMirror.LocationAdapter = DS.RESTAdapter.extend
    host    : 'http://ipinfo.io'
    service : ''

    buildURL: (type, id)->
        "#{@get('host')}"
    
    find: (id)->
        deferred = new Ember.$.Deferred()
        $.getJSON(@buildURL()).then (location)=>           
            deferred.resolve
                'location' :
                    'id'   : 1
                    'city' : location.city
                    'abbr' : location.country
        , (error) =>
            deferred.resolve
                'location' :
                    'id'   : 1
                    'city' : 'Stockholm'
                    'abbr' : 'SE'
        deferred.promise()

    findAll:(store, type, sinceToken)-> @find()