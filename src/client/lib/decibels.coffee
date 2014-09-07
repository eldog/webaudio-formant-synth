class @Decibels
  @dbToGain: (db) ->
    Math.pow(10, db / 10)

  @gainToDb: (gain) ->
    10 * Decibels._log10(gain)

  @_log10: (x) ->
    Math.log(x) / Math.LN10

