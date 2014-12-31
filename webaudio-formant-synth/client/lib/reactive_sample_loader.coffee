class @ReactiveSampleLoader
  constructor: (@_ctx, url) ->
    @_buffer = new ReactiveVar
    @_request = new XMLHttpRequest
    @_request.open 'GET', url, true
    @_request.responseType = 'arraybuffer'
    @_request.onload = @_onRequestLoad
    @_request.send()

  _onRequestLoad: =>
    @_ctx.decodeAudioData @_request.response, (buffer) =>
      @_buffer.set buffer

  getBuffer: ->
    @_buffer.get()

