class @WetDryFx
  constructor: (@_ctx, @_fxNode) ->
    @_splitter = @_ctx.createGain()
    @_wetGain = @_ctx.createGain()
    @_dryGain = @_ctx.createGain()
    @_splitter.connect(@_fxNode)
    @_splitter.connect(@_dryGain)
    @_fxNode.connect(@_wetGain)
    max = 1
    @_wetGain.gain.value = 0.2
    @wetness = new RangeValue(@_wetGain.gain, 'wetness',
      min: 0
      max: max
      step: 0.01
    )
    Tracker.autorun =>
      gain = @wetness.getValue()
      @_dryGain.gain.value = max - gain

  connect: (destination) ->
    @_wetGain.connect(destination)
    @_dryGain.connect(destination)

  getNode: ->
    @_splitter

