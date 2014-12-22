class @BandPassProxy
  constructor: (@_index, @_noteMap, frequency, q, db) ->
    @_frequency = new ReactiveVar(frequency)
    @_q = new ReactiveVar(q)
    @_db = new ReactiveVar(db)
    @_computation = Tracker.autorun =>
      frequency = @_frequency.get()
      q = @_q.get()
      db = @_db.get()
      for note, synth of @_noteMap
        bandpass = synth.getBandPasses()[@_index]
        bandpass.setFreq(frequency)
        bandpass.setQ(q)
        bandpass.setGain(db)

  stop: ->
    @_computation.stop()

  getFrequency: ->
    @_frequency.get()

  setFrequency: (frequency) ->
    @_frequency.set(frequency)

  getQ: ->
    @_q.get()

  setQ : (q) ->
    @_q.set(q)

  getDb: ->
    @_db.get()

  setDb: (db) ->
    @_db.set(db)

