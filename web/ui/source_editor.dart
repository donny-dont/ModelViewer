part of viewer;

/// Callback for when the source code is changed.
typedef void SourceCodeEvent(String value);

/**
 * Editor for modifying source code.
 */
class SourceEditor
{
  /**
   * The amount of time to wait until attempting to compile the shader.
  *
   * This is so the user has time to type, and so the shader isn't
   * being compiled constantly.
   */
  const int _compileDelay = 1000;
  /// The [TextAreaElement] holding the source code.
  TextAreaElement _sourceCode;
  /// The time to compile the source.
  int _compileSourceAt;
  /// Callback for when the source changed.
  SourceCodeEvent sourceCallback;

  /**
   * Creates a [SourceEditor] from the given [id].
   */
  SourceEditor(String id)
  {
    _sourceCode = query(id);
    assert(_sourceCode != null);

    _sourceCode.on.keyUp.add((_) {
      Date date = new Date.now();
      _compileSourceAt = date.millisecondsSinceEpoch + _compileDelay;

      Timer timer = new Timer(_compileDelay, (_) {
        _onSourceChanged();
      });
    });

    _compileSourceAt = 0;
  }

  /// The source code contained in the editor.
  String get source => _sourceCode.value;
  set source(String value)
  {
    _sourceCode.value = value;
  }

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
}
