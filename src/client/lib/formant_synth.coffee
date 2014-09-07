class @FormantSynth
  constructor: (@_ctx) ->
    @_bandPassesDep = new Tracker.Dependency
    @_bandPasses = []
    @_frequencyDep = new Tracker.Dependency
    @_started = false
    @_startedDep = new Tracker.Dependency
    @_freq = 100
    @_vibosc = @_ctx.createOscillator()
    @_masterGain = @_ctx.createGain()
    @_masterGain.connect(@_ctx.destination)
    @_masterGain.gain.value = 1
    @_createAndConnectBandPass(600, 60, 0)
    @_createAndConnectBandPass(1040, 70, -7)
    @_createAndConnectBandPass(2250, 110, -9)
    @_createAndConnectBandPass(2450, 120, -9)
    @_createAndConnectBandPass(2750, 130, -20)
    @_vibosc.frequency.value = 4
    @_vibosc.start()

  _createAndConnectBandPass: (freq, q, gain) ->
    @_bandPasses.push(new BandPass(@_ctx, freq, q, gain))
    @_bandPassesDep.changed()

  getBandPasses: ->
    @_bandPassesDep.depend()
    @_bandPasses

  getFrequency: ->
    @_frequencyDep.depend()
    @_freq

  getState: ->
    @_startedDep.depend()
    @_started

  setFrequency: (frequency) ->
    @_freq = frequency
    if @_osc?
      @_osc.frequency.value = frequency
    @_frequencyDep.changed()

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

