part of viewer;

/// Callback for when the source code is changed.
typedef void SourceCodeEvent(String value);

/**
 * Editor for modifying source code.
 */
class SourceEditor
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /**
   * The amount of time to wait until attempting to compile the shader.
  *
   * This is so the user has time to type, and so the shader isn't
   * being compiled constantly.
   */
  static const int _compileDelay = 1000;
  /// Class for an error.
  static const String _errorClassName = 'error_at';
  /// Class for a warning.
  static const String _warningClassName = 'warning_at';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [TextAreaElement] holding the source code.
  TextAreaElement _sourceCode;
  /// The [DivElement] containing the code lines.
  DivElement _codeLines;
  /// The number of lines
  int _lineCount;
  /// The time to compile the source.
  int _compileSourceAt;
  /// Callback for when the source changed.
  SourceCodeEvent sourceCallback;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates a [SourceEditor].
   *
   * The textarea ID is specified in [textId], while the line numbers
   * are specified in [lineNumbersId].
   */
  SourceEditor(String textId, String lineNumbersId)
  {
    // Setup the source area
    _sourceCode = query(textId);
    assert(_sourceCode != null);

    _sourceCode.on.keyUp.add((_) {
      print('Scroll height ${_sourceCode.scrollHeight}');
      Date date = new Date.now();
      _compileSourceAt = date.millisecondsSinceEpoch + _compileDelay;
      _createLineNumbers();

      Timer timer = new Timer(_compileDelay, (_) {
        _onSourceChanged();
      });
    });

    _sourceCode.on.scroll.add(_onSourceScrolled);
    _compileSourceAt = 0;

    // Setup the line numbers area
    _codeLines = query(lineNumbersId);
    assert(_codeLines != null);

    _lineCount = 0;
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The source code contained in the editor.
  String get source => _sourceCode.value;
  set source(String value)
  {
    _sourceCode.value = value;
    _createLineNumbers();
  }

  //---------------------------------------------------------------------
  // Code line methods
  //---------------------------------------------------------------------

  /**
   * Sets an error at the specified point.
   */
  void setErrorsAt(List<int> lineNumbers)
  {
    _setMessageAt(lineNumbers, _errorClassName);
  }

  /**
   * Sets an error at the specified point.
   */
  void setWarningsAt(List<int> lineNumbers)
  {
    _setMessageAt(lineNumbers, _warningClassName);
  }

  /**
   * Sets a message at the given line numbers.
   */
  void _setMessageAt(List<int> lineNumbers, String className)
  {
    int errors = lineNumbers.length;
    var lines = _codeLines.nodes;

    for (int i = 0; i < errors; ++i)
    {
      // Offset by 1 as the first node is Text.
      lines[lineNumbers[i] + 1].classes.add(className);
    }
  }

  /**
   * Clear any errors or warnings associated with the source code.
   */
  void clearErrors()
  {
    var lines = _codeLines.nodes;
    int length = lines.length;

    // Start at 1 since 0 is Text
    for (int i = 1; i < length; ++i)
    {
      Element line = lines[i];

      line.classes.remove(_errorClassName);
      line.classes.remove(_warningClassName);
    }
  }

  /**
   * Create the line numbers.
   */
  void _createLineNumbers()
  {
    double linesNum = _sourceCode.scrollHeight / 15.0;
    int lines = linesNum.toInt();

    if (_lineCount > lines)
    {
      // Remove lines
      List<Element> toRemove = new List<Element>();
      int length = _codeLines.nodes.length;

      // Increment by 1 as the first element is Text
      for (int i = lines + 1; i < length; ++i)
      {
        toRemove.add(_codeLines.nodes[i]);
      }

      for (Element element in toRemove)
      {
        element.remove();
      }
    }
    else
    {
      // Add lines
      for (int i = _lineCount; i < lines; ++i)
      {
        DivElement lineNum = new DivElement();
        lineNum.innerHTML = i.toString();

        _codeLines.nodes.add(lineNum);
      }
    }

    _lineCount = lines;
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when the text is changed.
   */
  void _onSourceChanged()
  {
    if (sourceCallback != null)
    {
      Date date = new Date.now();
      if (_compileSourceAt > date.millisecondsSinceEpoch)
        return;

      sourceCallback(source);
    }
  }

  /**
   * Callback for when the text is scrolled.
   */
  void _onSourceScrolled(_)
  {
    _codeLines.style.marginTop = '-${_sourceCode.scrollTop}px';
  }
}
