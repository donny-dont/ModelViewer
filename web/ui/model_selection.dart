part of viewer;

/// Callback type for when the model is changed.
typedef void ModelChangedEvent(String url);
/// Callback type for when a model is loaded.
typedef void ModelLoadedEvent(File file);

/**
 * UI for interacting with Models.
 */
class ModelSelection
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Text to display when hovering over the drop area.
  static const String _dropText = 'Drag and Drop a Model to Change';
  /// Class to use when the model is selected.
  static const String _modelSelectedClass = 'model_selected';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Callback for when a model change request occurs
  ModelChangedEvent modelChangedCallback;
  /// Callback for when a model is loaded.
  ModelLoadedEvent modelLoadedCallback;
  /// Model selection.
  List<DivElement> _modelElements;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [ModelSelection] class.
   */
  ModelSelection()
  {
    _setupStandardModels();
    _setupModelLoadArea();
  }

  /**
   * Sets up the standard model buttons.
   */
  void _setupStandardModels()
  {
    _modelElements = new List<DivElement>();

    DivElement cubeMesh = query('#cube_button') as DivElement;
    cubeMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/cube.mesh', 0);
    });

    _modelElements.add(cubeMesh);

    DivElement sphereMesh = query('#sphere_button');
    sphereMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/sphere.mesh', 1);
    });

    _modelElements.add(sphereMesh);

    DivElement planeMesh = document.query('#plane_button');
    planeMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/plane.mesh', 2);
    });

    _modelElements.add(planeMesh);

    DivElement cylinderMesh = query('#cylinder_button');
    cylinderMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/cylinder.mesh', 3);
    });

    _modelElements.add(cylinderMesh);
  }

  /**
   * Sets up the model loading functionality.
   */
  void _setupModelLoadArea()
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

    modelDropArea.on.dragOver.add((e) {
      e.stopPropagation();
      e.preventDefault();
    });

    modelDropArea.on.drop.add((e) {
      e.stopPropagation();
      e.preventDefault();

      modelDropArea.classes.remove('drop_over');
      modelDropArea.classes.add('drag_none');

      _onModelLoaded(e.dataTransfer.files);
    });

    modelDropArea.on.mouseOver.add((_) {
      dropText.classes.remove('hidden');
    });
    modelDropArea.on.mouseOut.add((_) {
      dropText.classes.add('hidden');
    });
  }

  //---------------------------------------------------------------------
  // Methods
  //---------------------------------------------------------------------

  /**
   * Shows what model is currently selected.
   */
  void _showSelectedModel(int index)
  {
    // Show the current selection
    int length = _modelElements.length;

    for (int i = 0; i < length; ++i)
    {
      DivElement element = _modelElements[i];

      if (i == index)
      {
        element.classes.add(_modelSelectedClass);
      }
      else
      {
        element.classes.remove(_modelSelectedClass);
      }
    }
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when one of the standard meshes are selected.
   */
  void _onModelChanged(String url, int index)
  {
    if (modelChangedCallback != null)
    {
      _showSelectedModel(index);

      modelChangedCallback(url);
    }
  }

  /**
   * Callback for when a model file is loaded.
   */
  void _onModelLoaded(List<File> files)
  {
    if (modelLoadedCallback != null)
    {
      // Use a custom mesh so hide any selected models.
      _showSelectedModel(-1);

      modelLoadedCallback(files[0]);
    }
  }
}
