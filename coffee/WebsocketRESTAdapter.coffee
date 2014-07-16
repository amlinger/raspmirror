
WebsocketRESTAdapter = DS.Adapter.extend
    defaultSerializer: '-rest',
    
    init:->
        #@set 'socket'. new WebSocket("ws://localhost:5000/socket/server/startDaemon.php");
        null

    updatedModel: ->
        null

    createRecord:->
        null

    updateRecord:->
        null

    deleteRecord:->
        null

    #
    # @method find
    # @param {DS.Store} store
    # @param {subclass of DS.Model} type
    # @param {String} id
    # @return {Promise} promise
    find: (store, type, id)->
        { 'category' : 
            'id'         : 14
            'name'       : 'hej'
            'created_at' : new Date().toTimeString() 
            'updated_at' : new Date().toTimeString() 
        }
    
    findMany: ->
        null
    # Called by the store in order to fetch a JSON array for all
    # of the records for a given type.
    # 
    # The `findAll` method makes an Ajax (HTTP GET) request to a URL computed by `buildURL`, and returns a
    # promise for the resulting payload.
    # 
    # @private
    # @method findAll
    # @param {DS.Store} store
    # @param {subclass of DS.Model} type
    # @param {String} sinceToken
    # @return {Promise} promise
    #
    findAll:(store, type, sinceToken)->
        query
        if (sinceToken)
            query = { since: sinceToken }
        #this.ajax(this.buildURL(type.typeKey), 'GET', { data: query });

    #
    # Called by the store in order to fetch a JSON array for
    # the records that match a particular query.
    # 
    # The `findQuery` method makes an Ajax (HTTP GET) request to a URL computed by `buildURL`, and returns a
    # promise for the resulting payload.
    # 
    # The `query` argument is a simple JavaScript object that will be passed directly
    # to the server as parameters.
    # 
    # @private
    # @method findQuery
    # @param {DS.Store} store
    # @param {subclass of DS.Model} type
    # @param {Object} query
    # @return {Promise} promise
    #
    findQuery:(store, type, query)->
        #this.ajax(this.buildURL(type.typeKey), 'GET', { data: query });
        null

