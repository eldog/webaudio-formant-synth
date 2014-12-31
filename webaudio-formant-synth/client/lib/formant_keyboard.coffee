START_OCTAVE = 0
END_OCTAVE = 8

NOTES = [
  'A'
  'A#'
  'B'
  'C'
  'C#'
  'D'
  'D#'
  'E'
  'F'
  'F#'
  'G'
  'G#'
]

VOWELS = [
  name: 'Bass A'
  frequency: 100
  vibrato: 4
  values: [
    [600, 60, 0]
    [1040, 70, -11]
    [2250, 110, -15]
    [2450, 120, -16]
    [2750, 120, -17]
  ]
,
  name: 'Bass E'
  frequency: 100
  vibrato: 4
  values: [
    [400, 40, 0]
    [1620, 80, -12]
    [2400, 100, -9]
    [2800, 120, -12]
    [3100, 120, -18]
  ]
,
  name: 'Bass I'
  frequency: 100
  vibrato: 4
  values: [
    [250, 60, 0]
    [1750, 90, -10]
    [2600, 100, -16]
    [3050, 120, -22]
    [3340, 120, -28]
  ]
,
  name: 'Bass O'
  frequency: 100
  vibrato: 4
  values: [
    [400, 40, 0]
    [750, 80, -11]
    [2400, 100, -21]
    [2600, 120, -20]
    [2900, 120, -40]
  ]
]

class @FormantKeyboard
  constructor: (ctx, midi) ->
    @_noteMap = {}
    @_vibrato = new ReactiveVar(0)
    @_vibratoDepth = new ReactiveVar(0)
    @_attack = new ReactiveVar(0)
    @_release = new ReactiveVar(0)
    @_voiceIndex = 0
    @_voice = VOWELS[@_voiceIndex]
    @_bandPasses = new ReactiveVar([])
    for octave in [0..END_OCTAVE - START_OCTAVE]
      for note in NOTES
        @_noteMap["#{note}#{octave}"] = new FormantSynth(
          ctx,
          midi
        )
    @_setVoice(@_voice)

  connect: (destination) ->
    for noteName, synth of @_noteMap
      synth.connect(destination)

  start: ->

  playNote: (note, frequency) =>
    synth = @_noteMap[note]
    unless synth.getState()
      synth.start()
    synth.setFrequency(frequency)
    synth.setGain(0, @_attack.get(), 0)

  stopNote: (note, frequency) =>
    synth = @_noteMap[note]
    synth.setFrequency(frequency)
    synth.setGain(-Infinity, @_release.get())

  getBandPasses: ->
    @_bandPasses.get()

  getVibrato: ->
    @_vibrato.get()

  setVibrato: (value) ->
    for note, synth of @_noteMap
      synth.setVibrato(value)
    @_vibrato.set(value)

  getVibratoDepth: ->
    @_vibratoDepth.get()

  setVibratoDepth: (value) ->
    for note, synth of @_noteMap
      synth.setVibratoDepth(value)
    @_vibratoDepth.set(value)

  getAttack: ->
    @_attack.get()

  setAttack: (attack) ->
    @_attack.set(attack)

  getRelease: ->
    @_release.get()

  setRelease: (release) ->
    @_release.set(release)

  isStarted: ->

  getVoice: ->
    @_voice

  getAvailableVoices: ->
    VOWELS

  _setVoice: (voice) ->
    for noteName, synth of @_noteMap
      synth.setVoice(voice)
    for bandpass in @_bandPasses.get()
      bandpass.stop()
    bandPasses = for bandpassValues, index in voice.values
      new BandPassProxy(
        index,
        @_noteMap,
        bandpassValues[0],
        bandpassValues[1],
        bandpassValues[2]
      )
    @_bandPasses.set(bandPasses)

  setVoice: (name) ->
    for vowel, index in VOWELS
      continue unless vowel.name == name
      @_vibrato.set(vowel.vibrato)
      @_setVoice(vowel)

