

Template.bandpass.helpers
  Q: ->
    this.getQ().toFixed(2)
  freq: ->
    this.getFreq().toFixed(2)
  gain: ->
    this.getGain().toFixed(2)

Template.bandpass.events
  'input [name="Q"]': (event) ->
    this.setQ(parseFloat($(event.target).val()))

  'input [name="freq"]': (event) ->
    this.setFreq(parseFloat($(event.target).val()))

  'input [name="gain"]': (event) ->
    this.setGain(parseFloat($(event.target).val()))
