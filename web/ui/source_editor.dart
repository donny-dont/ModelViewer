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
  /**
   * The [DivElement] containing the code lines.
   *
   * The div has Text as its first node. The lines of code
   * will be starting at index 1.
   */
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

    // Remove spellcheck!
    _sourceCode.spellcheck = false;

    // Add events
    _sourceCode.on.keyUp.add((_) {
      print('Scroll height ${_sourceCode.scrollHeight}');
      Date date = new Date.now();
      _compileSourceAt = date.millisecondsSinceEpoch + _compileDelay;
      _calculateLineNumbers();

      Timer timer = new Timer(_compileDelay, (_) {
        _onSourceChanged();
      });
    });

    _sourceCode.on.scroll.add(_onSourceScrolled);
    _compileSourceAt = 0;

    // Setup the line numbers area
    _codeLines = query(lineNumbersId);
    assert(_codeLines != null);

    // Just set the line count manually
    // Appears that the text area doesn't have a height if its hidden,
    // so this is a workaround to make sure line numbers are present.
    _lineCount = 0;
    _createLineNumbers(46);
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The source code contained in the editor.
  String get source => _toAscii(_sourceCode.value);
  set source(String value)
  {
    _sourceCode.value = _toUnicode(value);
    _calculateLineNumbers();
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
      lines[lineNumbers[i]].classes.add(className);
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
   * Calculates the line numbers required.
   */
  void _calculateLineNumbers()
  {
    double linesNum = _sourceCode.scrollHeight / 15.0;
    int lines = linesNum.toInt();

    _createLineNumbers(lines);
  }

  /**
   * Create the line numbers.
   */
  void _createLineNumbers(int lines)
  {
    if (lines == 0)
      return;

    if (_lineCount > lines)
    {
      // Remove lines
      List<Element> toRemove = new List<Element>();
      int length = _codeLines.nodes.length;

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
      for (int i = _lineCount + 1; i <= lines; ++i)
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

  //---------------------------------------------------------------------
  // Static methods
  //---------------------------------------------------------------------

  /**
   * Removes unicode characters.
   *
   * The textarea ends up containing unicode characters within it, so
   * this will strip them.
   */
  static String _toAscii(String value)
  {
    StringBuffer buffer = new StringBuffer();
    int length = value.length;

    for (int i = 0; i < length; ++i)
    {
      int charCode = value.charCodeAt(i);

      if (charCode == 160)
      {
        buffer.add(' ');
      }
      else if ((charCode >= 0) && (charCode < 128))
      {
        buffer.addCharCode(charCode);
      }
      else
      {
        print('Warning unknown character code at $i: $charCode');
      }
    }

    return buffer.toString();
  }

  /**
   * Adds unicode space characters.
   *
   * The textarea wants unicode characters for leading spaces. So add
   * them in.
   */
  static String _toUnicode(String value)
  {
    StringBuffer buffer = new StringBuffer();

    List<String> lines = value.split('\n');

    for (String line in lines)
    {
      int length = line.length;
      int i = 0;

      // Look for leading spaces
      for (; i < length; ++i)
      {
        int charCode = line.charCodeAt(i);

        if (charCode == 32)
        {
          buffer.addCharCode(160);
        }
        else
        {
          break;
        }
      }

      // Add the rest of the string
      for (; i < length; ++i)
      {
        buffer.addCharCode(line.charCodeAt(i));
      }

      // Add end line
      buffer.addCharCode(10);
    }

    return buffer.toString();
  }
}
