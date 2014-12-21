class @Oscilloscope
  constructor: (@_audioContext, @_canvas) ->
    gain = @_audioContext.createGain()
    gain.gain.value = 0
    gain.connect @_audioContext.destination
    @processor = @_audioContext.createScriptProcessor 256, 1, 1
    @processor.onaudioprocess = @_onAudioProcess
    @processor.connect gain
    @_plot()

  _onAudioProcess: (audioProcessingEvent) =>
    @_data = audioProcessingEvent.inputBuffer.getChannelData 0

  _plot: =>
    requestAnimationFrame @_plot
    return unless @_data

    ctx = @_canvas.getContext '2d'
    canvasWidth = @_canvas.width
    canvasHeight = @_canvas.height
    canvasHalfHeight = canvasHeight * 0.5
    ctx.fillStyle = 'rgba(0, 0, 0, 0.15)'
    ctx.fillRect 0, 0, canvasWidth, canvasHeight
    ctx.lineWidth = 1
    ctx.strokeStyle = 'rgb(0, 255, 0)'
    ctx.beginPath()
    sliceWidth = canvasWidth / @_data.length
    x = 0
    for amplitude, i in @_data
      v = 1 - amplitude
      y = v * canvasHalfHeight
      if i == 0
        ctx.moveTo x, y
      else
        ctx.lineTo x, y
      x += sliceWidth
    ctx.lineTo canvasWidth, canvasHalfHeight
    ctx.stroke()

