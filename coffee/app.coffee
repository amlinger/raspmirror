window.MagicMirror              = Ember.Application.create
  LOG_TRANSITIONS : true

MagicMirror.ApplicationAdapter  = WebsocketRESTAdapter

MagicMirror.Router.map ->
  @route 'application', path : '/'
            
MagicMirror.ObjectTransform = DS.Transform.extend
  serialize:   (serialized) ->
    if Ember.isNone(serialized)   then {} else serialized
  deserialize: (deserialized) ->
    if Ember.isNone(deserialized) then {} else deserialized

