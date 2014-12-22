Template.bandpass.helpers
  Q: ->
    console.log this
    this.getQ().toFixed(2)
  freq: ->
    this.getFrequency().toFixed(2)
  gain: ->
    this.getDb().toFixed(2)

Template.bandpass.events
  'input [name="Q"]': (event) ->
    event.stopImmediatePropagation()
    this.setQ(parseFloat($(event.target).val()))

  'input [name="freq"]': (event) ->
    event.stopImmediatePropagation()
    this.setFrequency(parseFloat($(event.target).val()))

  'input [name="gain"]': (event) ->
    event.stopImmediatePropagation()
    this.setDb(parseFloat($(event.target).val()))
