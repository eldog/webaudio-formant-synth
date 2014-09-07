class @MIDI
  constructor: ->
    @_inputsDep = new Tracker.Dependency
    @_velocityDep = new Tracker.Dependency
    @_noteDep = new Tracker.Dependency

  start: ->
    if navigator.requestMIDIAccess
      navigator.requestMIDIAccess().then(_.bind(@_midiStarted, this), @_midiError)

  _midiError: (error) ->
    console.log("MIDI not initialized: " + err.code)

  _midiStarted: (@_midiHandle) ->
    @_inputs = @_midiHandle.inputs()
    @_inputsDep.changed()

  getInputs: ->
    @_inputsDep.depend()
    @_inputs

  setInput: (inputName) ->
    for input in @_inputs
      continue unless input.name == inputName
      input.onmidimessage = _.bind(@_handleMidiMessage, this)
      break

  _handleMidiMessage: (msg) ->
    channel = msg.data[0] & 0xf
    cmd = msg.data[0] >> 4

    return if channel == 9 and cmd != 9

    @_velocity = msg.data[2]
    @_note = msg.data[1]
    @_velocityDep.changed()
    @_noteDep.changed()

  getVelocity: ->
    @_velocityDep.depend()
    @_velocity

  getNote: ->
    @_noteDep.depend()
    @_note
