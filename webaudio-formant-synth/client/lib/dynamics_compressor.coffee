class @DynamicsCompressor
  constructor: (@_ctx) ->
    @_dynamicsCompressor = @_ctx.createDynamicsCompressor()
    @threshold = new RangeValue @_dynamicsCompressor.threshold, 'threshold',
      min: -100
      max: 0
    @knee = new RangeValue @_dynamicsCompressor.knee, 'knee',
      min: 0
      max: 40
    @ratio = new RangeValue @_dynamicsCompressor.ratio, 'ratio',
      min: 1
      max: 20
    @attack = new RangeValue @_dynamicsCompressor.attack, 'attack',
      min: 0
      max: 1
    @release = new RangeValue @_dynamicsCompressor.release, 'release',
      min: 0
      max: 1

  connect: (destination) ->
    @_dynamicsCompressor.connect(destination)

  getNode: ->
    @_dynamicsCompressor


