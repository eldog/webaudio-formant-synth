renderSample = (sample, buffer) ->
  OfflineAudioContext = getOfflineAudioContext()
  AudioContext = getAudioContext()
  sample.loadAudio new AudioContext(), (sample) ->
    length = sample.buffer.length
    offlineAudioContext = new OfflineAudioContext(1, length, 44100)
    pcm = PCMGen.getPCMFromSample offlineAudioContext, sample, (data) ->
      console.log("PCM", data)

Template.ga.created = ->
  OfflineAudioContext = getOfflineAudioContext()
  @offlineContext = new OfflineAudioContext(1, 44100 * 3, 44100)
  @formantSynth = new FormantSynth(@offlineContext, @data)
  ArrayBufferAudioSample.fromURL('/ahh.wav', renderSample)

Template.ga.events
  'click [name="evolve"]': (event, template) ->
    PCMGen.getPCMFromSynth template.offlineContext, template.formantSynth, (data) ->
      console.log(data)
