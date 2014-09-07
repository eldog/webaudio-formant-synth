class @NormalDistribution
  @_random: ->
   (Math.random()*2-1)+(Math.random()*2-1)+(Math.random()*2-1)

  @random: (mean, stddev) ->
    Math.round NormalDistribution._random() * stddev + mean

class @SynthEvolver
  constructor: (@formantSynth) ->

  mutate: ->
    parentVowel = @formantSynth.getVowel()
    parentVowel.frequency += NormalDistribution.random(parentVowel.frequency, 10)
    @formantSynth._connectVowelBandPasses(parentVowel)
