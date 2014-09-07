Template.synth.created = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
  @formantSynth = new FormantSynth(new AudioContext, @data)

Template.synth.helpers
  frequency: ->
    Template.instance().formantSynth.getFrequency()

  vibrato: ->
    Template.instance().formantSynth.getVibrato()

  gain: ->
    Template.instance().formantSynth.getGain().toFixed(2)

  vowels: ->
    Template.instance().formantSynth.getAvailableVowels()

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

  'input [name="vibrato"]': (event) ->
    value = parseFloat($(event.target).val())
    Template.instance().formantSynth.setVibrato(value)

  'input [name="gain"]': (event) ->
    value = parseFloat($(event.target).val())
    Template.instance().formantSynth.setGain(value)

  'change [name="vowel"]': (event) ->
    value = $(event.target).val()
    Template.instance().formantSynth.setVowel(value)

