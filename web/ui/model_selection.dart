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

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Callback for when a model change request occurs
  ModelChangedEvent modelChangedCallback;
  /// Callback for when a model is loaded.
  ModelLoadedEvent modelLoadedCallback;

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
    DivElement cubeMesh = query('#cube_button') as DivElement;
    cubeMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/cube.mesh');
    });

    DivElement sphereMesh = query('#sphere_button');
    sphereMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/sphere.mesh');
    });

    DivElement planeMesh = document.query('#plane_button');
    planeMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/plane.mesh');
    });

    DivElement cylinderMesh = query('#cylinder_button');
    cylinderMesh.on.click.add((_) {
      _onModelChanged('web/resources/meshes/cylinder.mesh');
    });

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
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when one of the standard meshes are selected.
   */
  void _onModelChanged(String url)
  {
    if (modelChangedCallback != null)
    {
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
      modelLoadedCallback(files[0]);
    }
  }
}
