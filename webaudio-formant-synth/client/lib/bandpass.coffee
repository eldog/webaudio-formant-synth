class @BandPass
  constructor: (ctx, freq, q, db) ->
    @dep                = new Tracker.Dependency
    @bp                 = ctx.createBiquadFilter()
    @gainNode           = ctx.createGain()
    @bp.type            = 'bandpass'
    @bp.frequency.value = freq
    @bp.Q.value         = q
    @gainNode.gain.value = Decibels.dbToGain(db)
    @bp.connect(@gainNode)

  connect: (src, dest) ->
    src.connect(@bp)
    @gainNode.connect(dest)

  disconnect: ->
    @bp.disconnect()

  getQ: ->
    @dep.depend()
    @bp.Q.value

  getFreq: ->
    @dep.depend()
    @bp.frequency.value

  getGain: ->
    @dep.depend()
    Decibels.gainToDb(@gainNode.gain.value)

  setQ: (value) ->
    @dep.changed()
    @bp.Q.value = value

  setFreq: (value) ->
    @dep.changed()
    @bp.frequency.value = value

  setGain: (value) ->
    @dep.changed()
    @gainNode.gain.value = Decibels.dbToGain(value)

