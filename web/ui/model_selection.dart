part of viewer;

/**
 * UI for interacting with Models.
 */
class ModelSelection
{
  /// Text to display when hovering over the drop area.
  static const String _dropText = 'Drag and Drop a Model to Change';

  /**
   * Creates an instance of the [ModelSelection] class.
   */
  ModelSelection()
  {
    _addModelArea();
  }

  void _addModelArea()
  {
    // Setup the model area
    DivElement modelDropArea = query('#model_drop');
    modelDropArea.classes.add('drop_none');

    ParagraphElement dropText = new ParagraphElement();
    dropText.innerHTML = _dropText;
    dropText.classes.add('hidden');
    modelDropArea.nodes.add(dropText);

    modelDropArea.on.dragEnter.add((_) {
      modelDropArea.classes.remove('drag_none');
      modelDropArea.classes.add('drag_over');
    });

    modelDropArea.on.dragLeave.add((_) {
      modelDropArea.classes.remove('drop_over');
      modelDropArea.classes.add('drag_none');
    });

    modelDropArea.on.mouseOver.add((_) {
      dropText.classes.remove('hidden');
    });
    modelDropArea.on.mouseOut.add((_) {
      dropText.classes.add('hidden');
    });
  }
}
