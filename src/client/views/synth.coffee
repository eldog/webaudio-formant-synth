Template.synth.created = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
  @formantSynth = new FormantSynth(new AudioContext)

Template.synth.helpers
  frequency: ->
    Template.instance().formantSynth.getFrequency()

  bandpasses: ->
    Template.instance().formantSynth.getBandPasses()

  synthState: ->
    state = Template.instance().formantSynth.getState()
    if state then 'Stop' else 'Start'

Template.synth.events
  'click [name="start"]': (event) ->
    Template.instance().formantSynth.toggle()

  'input [name="frequency"]': (event) ->
    value = parseFloat($(event.target).val())
    Template.instance().formantSynth.setFrequency(value)

