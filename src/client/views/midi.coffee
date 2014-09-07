Template.midi.created = ->
  @midi = new MIDI
  @midi.start()

Template.midi.helpers
  midiinputs: ->
    Template.instance().midi.getInputs()
  midi: ->
    return Template.instance().midi

Template.midi.events
  'change [name="midiinput"]': (event) ->
    Template.instance().midi.setInput($(event.target).val())
