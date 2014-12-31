toFixed = (number) ->
  number.toFixed(2)

Template.Range.helpers
  name: ->
    @range.getName()

  min: ->
    toFixed @range.getMin()

  max: ->
    toFixed @range.getMax()

  step: ->
    toFixed @range.getStep()

  value: ->
    toFixed @range.getValue()

Template.Range.events
  'input input': (event, template) ->
    template.data.range.setValue parseFloat($(event.target).val())


