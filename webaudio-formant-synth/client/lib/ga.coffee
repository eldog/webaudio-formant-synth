class @GA
  constructor: (@targetPCM, @targetLength) ->

  getFitness: ->
    OfflineAudioContext = getOfflineAudioContext()
    offlineContext = new OfflineAudioContext(1, @targetLength, 44100)
    formantSynth = new FormantSynth(offlineContext)
    PCMGen.getPCMFromSynth offlineContext, formantSynth, (data) =>
      sum = 0
      for i in [0...@targetLength]
        sum += Math.pow(@targetPCM[i] - data[i], 2)
      console.log(sum)
