class @RangeValue
  constructor: (@_audioParam, @_name, options = {}) ->
    options = _.defaults options,
      min: 0
      max: 100
      step: 0.1
    @_min = options.min
    @_max = options.max
    @_step = options.step
    @_value = new ReactiveVar(@_audioParam.value)

  getName: ->
    @_name

  getMin: ->
    @_min

  getMax: ->
    @_max

  getStep: ->
    @_step

  getValue: ->
    @_value.get()

  setValue: (value) ->
    @_audioParam.value = value
    @_value.set(@_audioParam.value)

