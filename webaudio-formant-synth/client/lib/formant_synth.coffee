class @FormantSynth
  constructor: (@_ctx, @midi) ->
    @_bandPassesDep = new Tracker.Dependency
    @_bandPasses = []
    @_frequencyDep = new Tracker.Dependency
    @_freq = 100
    @_started = false
    @_startedDep = new Tracker.Dependency
    @_vibratoDep = new Tracker.Dependency
    @_gainDep = new Tracker.Dependency
    @_vibosc = @_ctx.createOscillator()
    @_vibratoGain = @_ctx.createGain()
    @_vibratoGain.gain.value = 1
    @_masterGain = @_ctx.createGain()
    @_masterGain.gain.value = 1
    @_vibosc.start()
    return unless @midi?
    Tracker.autorun =>
      @midinote = @midi.getNote()
      @vel = @midi.getVelocity()
      @setFrequency(Math.pow(2, (@midinote - 69) / 12) * 440)
      @setVelocity(@vel)

  setVoice: (vowel) ->
    @_connectVowelBandPasses(vowel)
    if @_osc?
      for bandPass in @_bandPasses
        bandPass.connect(@_osc, @_masterGain)

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

  connect: (destination) ->
    @_masterGain.connect(destination)

  _createAndConnectBandPass: (freq, q, gain) ->
    @_bandPasses.push(new BandPass(@_ctx, freq, q, gain))
    @_bandPassesDep.changed()

  getBandPasses: ->
    @_bandPassesDep.depend()
    @_bandPasses

  getFrequency: ->
    @_frequencyDep.depend()
    @_freq

  setFrequency: (frequency) ->
    return unless frequency?
    @_freq = frequency
    if @_osc?
      @_osc.frequency.value = frequency
    @_frequencyDep.changed()

  getVibrato: ->
    @_vibratoDep.depend()
    @_vibosc.frequency.value

  setVibrato: (value) ->
    @_vibosc.frequency.value = value
    @_vibratoDep.changed()

  setVibratoDepth: (value) ->
    @_vibratoGain.gain.value = value

  setDetune: (value) ->
    @_osc?.detune.value = value

  getGain: ->
    @_gainDep.depend()
    Decibels.gainToDb(@_masterGain.gain.value)

  setGain: (value, delay, defaultValue) ->
    gain = Decibels.dbToGain(value)
    @setGainValue(gain, delay, defaultValue)

  setGainValue: (gain, delay, defaultValue) ->
    now = @_ctx.currentTime
    unless defaultValue?
      defaultValue = @_masterGain.gain.value
    @_masterGain.gain.cancelScheduledValues(now)
    # Always have some smooth gradient to prevent popping, as suggested in
    # http://stackoverflow.com/questions/16095519/removing-pop-hiss-from-webaudio-generated-sound
    @_masterGain.gain.setTargetAtTime(defaultValue, now, 0.01)
    @_masterGain.gain.linearRampToValueAtTime(gain, now + 0.001 + delay)
    @_gainDep.changed()

  setVelocity: (value) ->
    return unless value?
    @_masterGain.gain.value = value / 127
    @_gainDep.changed()

  getState: ->
    @_startedDep.depend()
    @_started


  start: ->
    if @_started
      throw new Exception 'Already started'
    @_osc = @_ctx.createOscillator()

    @_osc.type = 'sawtooth'
    @_osc.frequency.value = 0
    @_osc.start()
    @_vibosc.connect(@_vibratoGain)
    @_vibratoGain.connect(@_osc.detune)
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

