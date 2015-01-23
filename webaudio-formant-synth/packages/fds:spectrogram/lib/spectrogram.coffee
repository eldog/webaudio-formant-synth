class @Spectrogram
  constructor: (@_audioContext, @_container, options = {}) ->
    options = _.defaults
      fftSize: 2048
      useLogScale: true
      speed: 2
      nTicks: 20

    @_canvas = document.createElement('canvas')
    @_container.appendChild(@_canvas)
    @_labelCanvas = document.createElement('canvas')
    @_container.appendChild(@_labelCanvas)


    @_nTicks = options.nTicks
    @_fftSize = options.fftSize
    @_speed = options.speed
    @_useLogScale = options.useLogScale
    @_analyser = @_audioContext.createAnalyser()
    @_analyser.smoothingTimeConstant = 0
    @_analyser.fftSize = @_fftSize
    @_frequencies = new Uint8Array(@_analyser.frequencyBinCount)

    @_tempCanvas = document.createElement('canvas')
    @_ctx = @_canvas.getContext '2d'
    @_tempCtx = @_tempCanvas.getContext '2d'
    @_labelCtx = @_labelCanvas.getContext '2d'

    @_width = @_canvas.width
    @_height = @_canvas.height

    @_plot()

  connect: (destination) ->
    @_analyser.connect(destination)

  getNode: ->
    @_analyser

  _plot: =>
    requestAnimationFrame(@_plot)
    @_width = window.innerWidth
    @_height = window.innerHeight
    didResize = false
    if @_canvas.width != @_width
      @_canvas.width = @_width
      didResize = true
    if @_canvas.height != @_height
      @_canvas.height = @_height
      didResize = true
    @_renderFrequencyDomain()
    if didResize
      @_renderAxesLabels()

  _renderFrequencyDomain: ->
    @_analyser.getByteFrequencyData(@_frequencies)
    @_tempCanvas.width = @_width
    @_tempCanvas.height = @_height
    @_tempCtx.drawImage(@_canvas, 0, 0, @_width, @_height)

    for i in [0...@_frequencies.length]
      value = if @_useLogScale
        logIndex = @_logScale(i, @_frequencies.length)
        @_frequencies[logIndex]
      else
        @_frequencies[i]

      @_ctx.fillStyle = @_getFullColor(value)

      percent = i / @_frequencies.length
      y = Math.round(percent * @_height)
      @_ctx.fillRect(@_width - @_speed, @_height - y, @_speed, @_speed)

    @_ctx.translate(-@_speed, 0)
    @_ctx.drawImage(@_tempCanvas,
                    0, 0,
                    @_width, @_height,
                    0, 0,
                    @_width, @_height)
    @_ctx.setTransform(1, 0, 0, 1, 0, 0)


  _logScale: (index, total, base = 2) ->
    logMax = @_logBase(total + 1, base)
    exp = logMax * index / total
    Math.round(Math.pow(base, exp) - 1)

  _logBase: (value, base) ->
    Math.log(value) / Math.log(base)

  _getFullColor: (value) ->
    fromH = 255
    toH = 0
    percent = value / 255
    delta = percent * (toH - fromH)
    hue = fromH + delta
    "hsl(#{hue}, 100%, 50%)"

  _renderAxesLabels: ->
    @_labelCanvas.width = @_width
    @_labelCanvas.height = @_height
    startFrequency = 440
    nyquist = @_getNyquist()
    endFrequency = nyquist - startFrequency
    step = (endFrequency - startFrequency) / @_nTicks
    yLabelOffset = 5
    for i in [0...@_nTicks]
      frequency = startFrequency + (step * i)
      index = @_frequencyToIndex(frequency)
      percent = index / @_getFFTBinCount()
      y = (1 - percent) * @_height
      x = @_width - 60
      if @_useLogScale
        logIndex = @_logScale(index, @_getFFTBinCount())
        frequency = Math.max(1, @_indexToFrequency(logIndex))
      label = @_formatFrequency(frequency)
      units = @_formatUnits(frequency)
      @_labelCtx.font = '16px Inconsolata'
      @_labelCtx.textAlign = 'right'
      @_labelCtx.fillText(label, x, y + yLabelOffset)
      @_labelCtx.textAlign = 'left'
      @_labelCtx.fillText(units, x + 10, y + yLabelOffset)
      @_labelCtx.fillRect(x + 40, y, 30, 2)

  _getNyquist: ->
    nyquist = @_audioContext.sampleRate / 2

  _formatFrequency: (frequency) ->
    if frequency >= 1000
      (frequency / 1000).toFixed(1)
    else
      Math.round(frequency)

  _formatUnits: (frequency) ->
    if frequency >= 1000
      'KHz'
    else
      'Hz'

  _indexToFrequency: (index) ->
    @_getNyquist() / @_getFFTBinCount() * index

  _frequencyToIndex: (frequency) ->
    Math.round(frequency / @_getNyquist() * @_getFFTBinCount())

  _getFFTBinCount: ->
    @_fftSize / 2




