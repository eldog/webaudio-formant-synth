Template.synth.created = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
  @_audioContext = new AudioContext
  @_formantKeyboard = new FormantKeyboard(@_audioContext, @data)
  @_formantKeyboard.connect(@_audioContext.destination)
  @_formantKeyboard.start()

Template.synth.rendered = ->
  canvas = @find('#oscilloscope')
  @_oscilloscope = new Oscilloscope(@_audioContext, canvas)
  @_formantKeyboard.connect(@_oscilloscope.processor)

  @_keyboard = new QwertyHancock(
     id: 'keyboard'
     width: 600
     height: 150
     octaves: 2
     startNote: 'A2'
     whiteNotesColour: 'white'
     blackNotesColour: 'black'
     hoverColour: '#f3e939'
  )

  @_keyboard.keyDown = @_formantKeyboard.playNote

  @_keyboard.keyUp = @_formantKeyboard.stopNote


Template.synth.helpers
  vowels: ->
    Template.instance()._formantKeyboard.getAvailableVoices()

  vibrato: ->
    Template.instance()._formantKeyboard.getVibrato()

  vibratoDepth: ->
    Template.instance()._formantKeyboard.getVibratoDepth()

  bandpasses: ->
    Template.instance()._formantKeyboard.getBandPasses()

#  synthState: ->
#    state = Template.instance().formantSynth.getState()
#    if state then 'Stop' else 'Start'

Template.synth.events
  'click [name="start"]': (event) ->
    Template.instance().formantSynth.toggle()

  'input #vibrato-rate': (event) ->
    value = parseFloat($(event.target).val())
    Template.instance()._formantKeyboard.setVibrato(value)

  'input #vibrato-depth': (event, template) ->
    value = parseFloat($(event.target).val())
    template._formantKeyboard.setVibratoDepth(value)

  'change [name="vowel"]': (event) ->
    value = $(event.target).val()
    Template.instance()._formantKeyboard.setVoice(value)

