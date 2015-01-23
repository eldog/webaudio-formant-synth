
SAMPLE_NAME = 'hamilton-mausoleum-impulse-response-16bit.wav'

Template.synth.created = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
  @_audioContext = new AudioContext
  @_formantKeyboard = new FormantKeyboard(@_audioContext, @data)
  @data.setKeyboard(@_formantKeyboard)
  @_masterGain = new Gain(@_audioContext)

  @_liveInput = new LiveInput(@_audioContext)

  @_dynamicsCompressor = new DynamicsCompressor(@_audioContext)

  sampleLoader = new ReactiveSampleLoader @_audioContext, SAMPLE_NAME
  convolver = new Convolver(@_audioContext, sampleLoader)
  @_reverbFx = new WetDryFx(@_audioContext, convolver.getNode())

  @_formantKeyboard.connect(@_reverbFx.getNode())
  @_reverbFx.connect(@_masterGain.getNode())
  @_masterGain.connect(@_dynamicsCompressor.getNode())
  @_dynamicsCompressor.connect(@_audioContext.destination)

  @_formantKeyboard.start()

Template.synth.rendered = ->
  canvas = @find('#oscilloscope')
  @_oscilloscope = new Oscilloscope(@_audioContext, canvas)
  @_spectrogram = new Spectrogram(@_audioContext, @find('#spectrogram'))
  @_dynamicsCompressor.connect(@_oscilloscope.processor)
  @_dynamicsCompressor.connect(@_spectrogram.getNode())

  @autorun =>
    mediaStream = @_liveInput.getNode()
    if mediaStream?
      mediaStream.connect(@_spectrogram.getNode())
      mediaStream.connect(@_oscilloscope.processor)

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

  attack: ->
    Template.instance()._formantKeyboard.getAttack()

  release: ->
    Template.instance()._formantKeyboard.getRelease()

  dynamicsCompressor: ->
    Template.instance()._dynamicsCompressor

  gain: ->
    Template.instance()._masterGain

  reverbFx: ->
    Template.instance()._reverbFx

  dryMix: ->
    Template.instance()._dryMixGain

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

  'input #attack': (event, template) ->
    template._formantKeyboard.setAttack parseFloat($(event.target).val())

  'input #release': (event, template) ->
    template._formantKeyboard.setRelease parseFloat($(event.target).val())

