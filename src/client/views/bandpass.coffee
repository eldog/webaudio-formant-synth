Template.bandpass.helpers
  Q: ->
    this.getQ().toFixed(2)
  freq: ->
    this.getFreq().toFixed(2)
  gain: ->
    this.getGain().toFixed(2)

Template.bandpass.events
  'input [name="Q"]': (event) ->
    event.stopImmediatePropagation()
    this.setQ(parseFloat($(event.target).val()))

  'input [name="freq"]': (event) ->
    event.stopImmediatePropagation()
    this.setFreq(parseFloat($(event.target).val()))

  'input [name="gain"]': (event) ->
    event.stopImmediatePropagation()
    this.setGain(parseFloat($(event.target).val()))
