class @Convolver
  constructor: (@_ctx, @_reactiveSampleLoader) ->
    @_convolver = @_ctx.createConvolver()
    @_computation = Tracker.autorun =>
      buffer = @_reactiveSampleLoader.getBuffer()
      return unless buffer?
      @_convolver.buffer = buffer

  connect: (destination) ->
    @_convolver.connect destination

  getNode: ->
    @_convolver

  stop: ->
    @_computation.stop()

