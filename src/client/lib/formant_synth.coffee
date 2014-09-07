VOWELS = [
  name: 'Bass A'
  values: [
    [600, 60, 0]
    [1040, 70, -7]
    [2250, 110, -9]
    [2450, 120, -9]
    [2750, 120, -9]
  ]
,
  name: 'Bass E'
  values: [
    [400, 40, 0]
    [1620, 80, -12]
    [2400, 100, -9]
    [2800, 120, -12]
    [3100, 120, -18]
  ]
,
  name: 'Bass I'
  values: [
    [250, 60, 0]
    [1750, 90, -10]
    [2600, 100, -16]
    [3050, 120, -22]
    [3340, 120, -28]
  ]
,
  name: 'Bass O'
  values: [
    [400, 40, 0]
    [750, 80, -11]
    [2400, 100, -21]
    [2600, 120, -20]
    [2900, 120, -40]
  ]
]

class @FormantSynth
  constructor: (@_ctx) ->
    @_bandPassesDep = new Tracker.Dependency
    @_bandPasses = []
    @_frequencyDep = new Tracker.Dependency
    @_started = false
    @_startedDep = new Tracker.Dependency
    @_freq = 100
    @_vibratoDep = new Tracker.Dependency
    @_gainDep = new Tracker.Dependency
    @_vibosc = @_ctx.createOscillator()
    @_masterGain = @_ctx.createGain()
    @_masterGain.connect(@_ctx.destination)
    @_masterGain.gain.value = 1
    @_vibosc.frequency.value = 4
    @_vibosc.start()
    @_vowelIndex = 0
    @_connectVowelBandPasses()

  _connectVowelBandPasses: ->
    vowel = VOWELS[@_vowelIndex]
    for bandPass in @_bandPasses
      bandPass.disconnect()
    @_bandPasses = []
    for [freq, q, gain] in vowel.values
      @_createAndConnectBandPass(freq, q, gain)

  _createAndConnectBandPass: (freq, q, gain) ->
    @_bandPasses.push(new BandPass(@_ctx, freq, q, gain))
    @_bandPassesDep.changed()

  getBandPasses: ->
    @_bandPassesDep.depend()
    @_bandPasses

  getFrequency: ->
    @_frequencyDep.depend()
    @_freq

  getVibrato: ->
    @_vibratoDep.depend()
    @_vibosc.frequency.value

  setVibrato: (value) ->
    @_vibosc.frequency.value = value
    @_vibratoDep.changed()

  getGain: ->
    @_gainDep.depend()
    Decibels.gainToDb(@_masterGain.gain.value)

  setGain: (value) ->
    @_masterGain.gain.value = Decibels.dbToGain(value)
    @_gainDep.changed()

  getState: ->
    @_startedDep.depend()
    @_started

  setFrequency: (frequency) ->
    @_freq = frequency
    if @_osc?
      @_osc.frequency.value = frequency
    @_frequencyDep.changed()

  getAvailableVowels: ->
    VOWELS

  setVowel: (name) ->
    for vowel, index in VOWELS
      continue unless vowel.name == name
      @_vowelIndex = index
      @_connectVowelBandPasses()
      if @_osc?
        for bandPass in @_bandPasses
          bandPass.connect(@_osc, @_masterGain)

  getVowelIndex: ->
    @_vowelIndex

  _start: ->
    @_osc = @_ctx.createOscillator()
    @_osc.type = 'sawtooth'
    @_osc.frequency.value = @_freq
    @_osc.start()
    @_vibosc.connect(@_osc.frequency)
    for bandPass in @_bandPasses
      bandPass.connect(@_osc, @_masterGain)
    @_started = true
    @_startedDep.changed()

  _stop: ->
    if @_osc?
      @_osc.stop()
    @_started = false
    @_startedDep.changed()

  toggle: ->
    unless @_started
      @_start()
    else
      @_stop()

