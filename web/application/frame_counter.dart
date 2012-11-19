part of viewer;

/**
 * Keeps track of the number of frames per second.
 */
class FrameCounter
{
  //---------------------------------------------------------------------
  // Class constants
  //---------------------------------------------------------------------

  static const double _msPerSecond = 1000.0;
  /// The maximum frames per second to graph.
  static const double _maxFps = 60.0;
  /// The lowest acceptable frame rate
  static const double _goodFps = 30.0;
  /// The default width of the canvas containing the [FrameCounter].
  static const int _defaultWidth = 100;
  /// The default height of the canvas containing the [FrameCounter].
  static const int _defaultHeight = 50;
  /// The default number of FPS timings to keep track of.
  static const int _defaultHistorySize = 30;
  /// The default padding around the edges of the canvas.
  static const double _defaultPadding = 5.0;
  /// The default height of the text being drawn.
  static const double _defaultTextHeight = 5.0;
  /// The default font to draw with.
  static const String _defaultFont = '12px "Lucida Console", Monaco, monospace';
  /// The default text color.
  static const String _defaultFontColor = '#070707';
  /// The default color for a good frame count
  static const String _defaultGoodFpsColor = '#0F0';
  /// The default color for a bad frame count
  static const String _defaultBadFpsColor = '#F00';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The number of frames encountered.
  int _frames;
  /// The time when the current second has expired.
  double _endTime;
  /// The number of FPS timings to keep track of.
  int _historySize;
  /// Holds the historic record of FPS over time.
  Queue<double> _historicFps;
  /// The [CanvasElement] holding the [FrameCounter].
  CanvasElement _canvas;
  /// The [CanvasRenderingContext2D] to draw to.
  CanvasRenderingContext2D  _context;
  /// The width of the canvas.
  int _canvasWidth;
  /// The height of the canvas.
  int _canvasHeight;
  /// The padding around the edges of the canvas.
  double _padding;
  /// The height of the text being displayed.
  double _textHeight;
  /// Computed width for each history item.
  double _fpsBarWidth;
  /// Maximum height for each history item.
  double _fpsBarHeight;
  /// The font to use.
  String _font;
  /// The color for text rendering.
  String _fontColor;
  /// The color to display for good fps values.
  String _goodFpsColor;
  /// The color to display for bad fps values
  String _badFpsColor;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Initializes an instance of the [FrameCounter] class.
   *
   * Draws to the canvas specified in [id], and keeps track of
   * [historySize] timings.
   */
  FrameCounter(String id, [int width = _defaultWidth, int height = _defaultHeight, int historySize = _defaultHistorySize])
    : _frames = 0
    , _endTime = 0.0
    , _historySize = historySize
    , _historicFps = new Queue<double>()
    , _canvasWidth = width
    , _canvasHeight = height
    , _padding = _defaultPadding
    , _textHeight = _defaultTextHeight
    , _font = _defaultFont
    , _fontColor = _defaultFontColor
    , _goodFpsColor = _defaultGoodFpsColor
    , _badFpsColor = _defaultBadFpsColor
  {
    // Don't forget to initialize any additional variables above
    // in the initializer list or here in the constructor body

    assert(_historySize >= 1);

    // Get the graphics context
    _canvas = document.query(id) as CanvasElement;
    assert(_canvas != null);

    _context = _canvas.context2d;

    // Setup the layout
    _resetLayout();
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /**
   * Retrieve the current frames per second calculation.
   */
  double get fps => (_historicFps.length != 0) ? _historicFps.last : 0.0;

  /**
   * The width of the canvas.
   */
  int get width => _canvasWidth;
  set width(int value)
  {
    _canvasWidth = value;
    _resetLayout();
  }

  /**
   * The height of the canvas.
   */
  int get height => _canvasHeight;
  set height(int value)
  {
    _canvasHeight = value;
    _resetLayout();
  }
  /**
   * The padding around the edges of the canvas.
   */
  double get padding => _padding;
  set padding(double value)
  {
    _padding = value;
    _resetLayout();
  }

  /**
   * The height of the text being displayed.
   */
  double get textHeight => _textHeight;
  set textHeight(double value)
  {
    _textHeight = value;
    _resetLayout();
  }

  /**
   * The font to use.
   */
  String get font => _font;
  set font(String value) { _font = value; }

  /**
   * The color for text rendering.
   */
  String get fontColor => _fontColor;
  set fontColor(String value) { _fontColor = value; }

  /**
   * The color to display for good fps values.
   */
  String get goodFpsColor => _goodFpsColor;
  set goodFpsColor(String value) { _goodFpsColor = value; }

  /**
   * The color to display for bad fps values.
   */
  String get badFpsColor => _badFpsColor;
  set badFpsColor(String value) { _badFpsColor = value; }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /**
   * Updates the [FrameCounter].
   *
   * This should be called once per frame with the associated [time]
   * in milliseconds.
   */
  void update(double time)
  {
    _frames++;

    if (time >= _endTime)
    {
      double currentFps = (_frames * _msPerSecond) / (_msPerSecond + (time - _endTime));
      _setFps(currentFps);

      // Reset the values
      _frames = 0;
      _endTime = time + _msPerSecond;
    }
  }

  /**
   * Draws the [FrameCounter].
   *
   * Uses a 2D rendering context to display a visualization of
   * the frames per second of an application. This only needs to be
   * called when the contents change.
   */
  void draw()
  {
    // Clear the canvas
    _context.clearRect(0, 0, _canvasWidth, _canvasHeight);

    // Draw the FPS text
    String fpsText = 'FPS: ${fps.toStringAsFixed(2)}';
    _context.font = _font;
    _context.fillStyle = _fontColor;
    _context.fillText(fpsText, _padding, _padding + _textHeight);

    // Draw the history
    double fpsOffset = _padding;
    double barHeightOffset = _textHeight + (2.0 * _padding);

    for (double item in _historicFps)
    {
      // Make a visual distinction between good and bad frame rates
      _context.fillStyle = (item >= _goodFps) ? _goodFpsColor : _badFpsColor;

      double height = (item >= _maxFps) ? _fpsBarHeight : _fpsBarHeight * (item / _maxFps);
      _context.fillRect(fpsOffset, barHeightOffset + (_fpsBarHeight - height), _fpsBarWidth, height);

      fpsOffset += _fpsBarWidth;
    }
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /**
   * Resets the layout for the [FrameCounter].
   */
  void _resetLayout()
  {
    // Set the canvas dimensions
    _canvas.width = _canvasWidth;
    _canvas.height = _canvasHeight;

    // Also needs to be explictly set in the style
    _canvas.style.width = '${_canvasWidth}px';
    _canvas.style.height = '${_canvasHeight}px';

    // Compute information for the bars
    double availableWidth = _canvasWidth - (2.0 * _padding);
    _fpsBarWidth = availableWidth / _historySize;
    _fpsBarHeight = _canvasHeight - _textHeight - (3.0 * _padding);

    // Force a draw to reset the layout
    draw();
  }

  /**
   * Sets the current fps value.
   *
   * Will trigger a redraw of the canvas.
   */
  void _setFps(double value)
  {
    if (_historicFps.length == _historySize)
      _historicFps.removeFirst();

    _historicFps.addLast(value);

    draw();
  }
}
