renderSample = (sample, buffer) ->
  OfflineAudioContext = getOfflineAudioContext()
  AudioContext = getAudioContext()
  sample.loadAudio new AudioContext(), (sample) ->
    length = sample.buffer.length
    offlineAudioContext = new OfflineAudioContext(1, length, 44100)
    pcm = PCMGen.getPCMFromSample offlineAudioContext, sample, (data) ->
      ga = new GA(data, length)
      ga.getFitness()

Template.ga.events
  'click [name="evolve"]': (event, template) ->
    ArrayBufferAudioSample.fromURL('/ahh.wav', renderSample)
