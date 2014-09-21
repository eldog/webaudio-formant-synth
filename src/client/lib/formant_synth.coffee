VOWELS = [
  name: 'Bass A'
  frequency: 100
  vibrato: 4
  values: [
    [600, 60, -6]
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

class @FormantSynth
  constructor: (@_ctx, defaultVoice, @midi) ->
    @_bandPassesDep = new Tracker.Dependency
    @_bandPasses = []
    @_frequencyDep = new Tracker.Dependency
    @_freq = 100
    @_started = false
    @_startedDep = new Tracker.Dependency
    @_vibratoDep = new Tracker.Dependency
    @_gainDep = new Tracker.Dependency
    @_vibosc = @_ctx.createOscillator()
    @_masterGain = @_ctx.createGain()
    @_dynamicCompressor = @_ctx.createDynamicsCompressor()
    @_masterGain.connect(@_dynamicCompressor)
    @_dynamicCompressor.connect(@_ctx.destination)
    @_masterGain.gain.value = 1
    @_vibosc.start()
    @_vowelIndex = 0
    if defaultVoice?
      @_connectVowelBandPasses(defaultVoice)
    else
      @_connectVowelBandPassesFromPreset()
    return unless @midi?
    Tracker.autorun =>
      @midinote = @midi.getNote()
      @vel = @midi.getVelocity()
      @setFrequency(Math.pow(2, (@midinote - 69) / 12) * 440)
      @setVelocity(@vel)

  _connectVowelBandPassesFromPreset: ->
    vowel = VOWELS[@_vowelIndex]
    @_connectVowelBandPasses(vowel)

  _connectVowelBandPasses: (vowel) ->
    for bandPass in @_bandPasses
      bandPass.disconnect()
    @_bandPasses = []
    for [freq, q, gain] in vowel.values
      @_createAndConnectBandPass(freq, q, gain)
    @_vibosc.frequency.value = vowel.vibrato
    @_vibratoDep.changed()
    @_freq = vowel.frequency
    @_frequencyDep.changed()
    @_vowel = vowel

  getVowel: ->
    @_vowel

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
    gain = Decibels.dbToGain(value)
    @setGainValue(gain)

  setGainValue: (gain) ->
    @_masterGain.gain.cancelScheduledValues(@_ctx.currentTime)
    @_masterGain.gain.linearRampToValueAtTime(gain, @_ctx.currentTime + 0.1)
    @_gainDep.changed()

  setVelocity: (value) ->
    return unless value?
    @_masterGain.gain.value = value / 127
    @_gainDep.changed()

  getState: ->
    @_startedDep.depend()
    @_started

  setFrequency: (frequency) ->
    return unless frequency?
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
      @_connectVowelBandPassesFromPreset()
      if @_osc?
        for bandPass in @_bandPasses
          bandPass.connect(@_osc, @_masterGain)

  getVowelIndex: ->
    @_vowelIndex

  start: ->
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
      @start()
    else
      @_stop()

