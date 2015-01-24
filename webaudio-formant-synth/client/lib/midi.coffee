class @MIDI
  constructor: ->
    @_inputsDep = new Tracker.Dependency
    @_velocityDep = new Tracker.Dependency
    @_noteDep = new Tracker.Dependency

  start: ->
    if navigator.requestMIDIAccess
      navigator.requestMIDIAccess().then(_.bind(@_midiStarted, this), @_midiError)

  setKeyboard: (@_keyboard) ->

  _midiError: (error) ->
    console.log("MIDI not initialized: " + err.code)

  _midiStarted: (@_midiHandle) ->
    @_inputs = []
    entries = @_midiHandle.inputs.entries()
    while true
      entry = entries.next()
      unless entry.value?
        break
      @_inputs.push entry.value[1]
      entry.value[1].onmidimessage = _.bind(@_handleMidiMessage, this)
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

    @_velocity = msg.data[2]
    @_note = msg.data[1]
    if @_velocity == 0
      # Count as note off event
      cmd = 8
    if @_keyboard?
      switch cmd
        when 9
          @_keyboard.playNoteByMidiNumber(@_note)
        when 8
          @_keyboard.stopNoteByMidiNumber(@_note)

  getVelocity: ->
    @_velocityDep.depend()
    @_velocity

  getNote: ->
    @_noteDep.depend()
    @_note
