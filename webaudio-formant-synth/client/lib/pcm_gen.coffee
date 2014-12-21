class @PCMGen
  @getPCMFromSynth: (offlineContext, formantSynth, callback) ->
    offlineContext.oncomplete = (event) ->
      callback(event.renderedBuffer.getChannelData(0))
    formantSynth.start()
    offlineContext.startRendering()

  @getPCMFromSample: (offlineContext, audioSample, callback) ->
    renderAudioSampleOffline = (audioSample) =>
      offlineContext.oncomplete = (event) ->
        callback event.renderedBuffer.getChannelData(0)
      audioSample.tryPlay()
      offlineContext.startRendering()
    audioSample.loadAudio offlineContext, renderAudioSampleOffline
