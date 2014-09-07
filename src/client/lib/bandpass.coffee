class @BandPass
  constructor: (ctx, freq, q, gain) ->
    @dep                = new Tracker.Dependency
    @bp                 = ctx.createBiquadFilter()
    @gainNode           = ctx.createGain()
    @bp.type            = 'bandpass'
    @bp.frequency.value = freq
    @bp.Q.value         = q
    @gainNode.gain.value = Math.pow(10, gain / 10)
    @bp.connect(@gainNode)

  connect: (src, dest) ->
    src.connect(@bp)
    @gainNode.connect(dest)

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



