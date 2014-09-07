formantSynth = null
formantSynthDep = new Tracker.Dependency

class BandPass
  constructor: (ctx, freq, q, gain, masterGain, osc) ->
    @dep                = new Tracker.Dependency
    @bp                 = ctx.createBiquadFilter()
    @gainNode           = ctx.createGain()
    @bp.type            = @bp.bandpass
    @bp.frequency.value = freq
    @bp.Q.value         = q
    @gainNode.gain.value = Math.pow(10, gain / 10)
    osc.connect(@bp)
    @bp.connect(@gainNode)
    @gainNode.connect(masterGain)

  log10: (x) ->
    Math.log(x) / Math.LN10

  getQ: ->
    @dep.depend()
    @bp.Q.value

  getFreq: ->
    @dep.depend()
    @bp.frequency.value

  getGain: ->
    @dep.depend()
    10 * @log10(@gainNode.gain.value)

  setQ: (value) ->
    @dep.changed()
    @bp.Q.value = value

  setFreq: (value) ->
    @dep.changed()
    @bp.frequency.value = value

  setGain: (value) ->
    @dep.changed()
    @gainNode.gain.value = Math.pow(10, value / 10)


class FormantSynth
  constructor: (@ctx) ->
    @bandpasses = []

  createAndConnectBandPass: (freq, q, gain) ->
    @bandpasses.push(new BandPass(@ctx, freq, q, gain,
                                  @masterGain, @osc))

  start: ->
    @osc = @ctx.createOscillator()
    @vibosc = @ctx.createOscillator()
    @masterGain = @ctx.createGain()
    @masterGain.connect(@ctx.destination)
    @masterGain.gain.value = 1
    @osc.type = 'sawtooth'
    @createAndConnectBandPass(600, 60, 0)
    @createAndConnectBandPass(1040, 70, -7)
    @createAndConnectBandPass(2250, 110, -9)
    @createAndConnectBandPass(2450, 120, -9)
    @createAndConnectBandPass(2750, 130, -20)
    @osc.frequency.value = 100
    @osc.start()
    @vibosc.frequency.value = 4
    @vibosc.connect(@osc.frequency)
    @vibosc.start()

startSynth = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
  formantSynth = new FormantSynth(new AudioContext)
  formantSynth.start()
  formantSynthDep.changed()
  Deps.autorun ->
    frequency = Session.get('frequency')
    return unless frequency?
    formantSynth.osc.frequency.value = frequency

Template.synth.helpers
  bandpasses: ->
    formantSynthDep.depend()
    return unless formantSynth?
    formantSynth.bandpasses 

Template.synth.events
  'click [name="start"]': (event) ->
    startSynth()

  'input [name="frequency"]': (event) ->
    value = parseFloat($(event.target).val())
    Session.set('frequency', value)

