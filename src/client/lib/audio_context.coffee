@getAudioContext = ->
  AudioContext = window.AudioContext
  AudioContext ?= window.webkitAudioContext
