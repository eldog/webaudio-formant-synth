@getOfflineAudioContext = ->
  OfflineAudioContext = window.OfflineAudioContext
  OfflineAudioContext ?= window.webkitOfflineAudioContext
