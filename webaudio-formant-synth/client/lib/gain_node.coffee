class @Gain
  constructor: (@_ctx, options = {}) ->
    options = _.defaults options,
      min: 0
      max: 100
    @_gain = @_ctx.createGain()
    @gain = new RangeValue @_gain.gain, 'gain', options

  connect: (destination) ->
    @_gain.connect destination

  getNode: ->
    @_gain

