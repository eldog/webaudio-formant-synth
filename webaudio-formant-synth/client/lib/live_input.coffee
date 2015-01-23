class @LiveInput
  constructor: (@_ctx) ->

    getUserMediaOptions =
      audio:
        mandatory:
          googEchoCancellation: false
          googAutoGainControl: false
          googNoiseSuppression: false
          googHighpassFilter: false
        optional: []

    @_liveInput = new ReactiveVar
    @_getUserMedia getUserMediaOptions

  _getUserMedia: (params) ->
    try
        navigator.getUserMedia = \
          navigator.getUserMedia or \
          navigator.webkitGetUserMedia or \
          navigator.mozGetUserMedia
        navigator.getUserMedia params, @_onUserMediaStream, @_onUserMediaError
    catch error
      alert "getUserMedia threw exception : #{error}"

  _onUserMediaStream: (stream) =>
    @_liveInput.set @_ctx.createMediaStreamSource(stream)

  _onUserMediaError: (error) ->
    console.error error

  getNode: ->
    @_liveInput.get()


