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

  /// The ID of the model drop area.
  static const String _modelDropName = '#model_drop';
  /// Class to use when the model is selected.
  static const String _modelSelectedClass = 'model_selected';
  /// Serialization name for a model.
  static const String _modelName = 'model';

  /// The index of a custom model.
  static const int _customModelIndex = -1;
  /// Serialization name for a custom model.
  static const String _customModelName = 'custom';

  /// The index of the cube model.
  static const int _cubeModelIndex = 0;
  /// Serialization name for a cube model.
  static const String _cubeModelName = 'cube';
  /// Path to the cube model.
  static const String _cubeModelPath = 'web/resources/meshes/cube.mesh';

  /// The index of the sphere model.
  static const int _sphereModelIndex = 1;
  /// Serialization name for a sphere model.
  static const String _sphereModelName = 'sphere';
  /// Path to the sphere model.
  static const String _sphereModelPath = 'web/resources/meshes/sphere.mesh';

  /// The index of the plane model.
  static const int _planeModelIndex = 2;
  /// Serialization name for a plane model.
  static const String _planeModelName = 'plane';
  /// Path to the plane model.
  static const String _planeModelPath = 'web/resources/meshes/plane.mesh';

  /// The index of the cylinder model.
  static const int _cylinderModelIndex = 3;
  /// Serialization name for a cylinder model.
  static const String _cylinderModelName = 'cylinder';
  /// Path to the cylinder model.
  static const String _cylinderModelPath = 'web/resources/meshes/cylinder.mesh';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Callback for when a model change request occurs
  ModelChangedEvent modelChangedCallback;
  /// Callback for when a model is loaded.
  ModelLoadedEvent modelLoadedCallback;
  /// Model selection.
  List<DivElement> _modelElements;
  /// The currently selected model.
  int _selectedModel;

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
    _showSelectedModel(_cubeModelIndex);
  }

  /**
   * Sets up the standard model buttons.
   */
  void _setupStandardModels()
  {
    _modelElements = new List<DivElement>();

    DivElement cubeMesh = query('#cube_button') as DivElement;
    cubeMesh.on.click.add((_) {
      _onModelChanged(_cubeModelPath, _cubeModelIndex);
    });

    _modelElements.add(cubeMesh);

    DivElement sphereMesh = query('#sphere_button');
    sphereMesh.on.click.add((_) {
      _onModelChanged(_sphereModelPath, _sphereModelIndex);
    });

    _modelElements.add(sphereMesh);

    DivElement planeMesh = document.query('#plane_button');
    planeMesh.on.click.add((_) {
      _onModelChanged(_planeModelPath, _planeModelIndex);
    });

    _modelElements.add(planeMesh);

    DivElement cylinderMesh = query('#cylinder_button');
    cylinderMesh.on.click.add((_) {
      _onModelChanged(_cylinderModelPath, _cylinderModelIndex);
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
    dropText.classes.add(_ElementNames.hiddenClass);
    modelDropArea.nodes.add(dropText);

    modelDropArea.on.dragEnter.add((_) {
      modelDropArea.classes.remove(_ElementNames.dragLeaveClassName);
      modelDropArea.classes.add(_ElementNames.dragOverClassName);
    });

    modelDropArea.on.dragLeave.add((_) {
      modelDropArea.classes.remove(_ElementNames.dragOverClassName);
      modelDropArea.classes.add(_ElementNames.dragOverClassName);
    });

    modelDropArea.on.dragOver.add((e) {
      e.stopPropagation();
      e.preventDefault();
    });

    modelDropArea.on.drop.add((e) {
      e.stopPropagation();
      e.preventDefault();

      modelDropArea.classes.remove(_ElementNames.dragOverClassName);
      modelDropArea.classes.add(_ElementNames.dragOverClassName);

      _onModelLoaded(e.dataTransfer.files);
    });

    modelDropArea.on.mouseOver.add((_) {
      dropText.classes.remove(_ElementNames.hiddenClass);
    });
    modelDropArea.on.mouseOut.add((_) {
      dropText.classes.add(_ElementNames.hiddenClass);
    });
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Saves the model information to a JSON.
   */
  Map toJson()
  {
    Map serialized = new Map();

    String model;

    switch (_selectedModel)
    {
      case _customModelIndex  : model = _customModelName;   break;
      case _cubeModelIndex    : model = _cubeModelName;     break;
      case _sphereModelIndex  : model = _sphereModelName;   break;
      case _planeModelIndex   : model = _planeModelName;    break;
      case _cylinderModelIndex: model = _cylinderModelName; break;
    }

    serialized[_modelName] = model;

    return serialized;
  }

  /**
   * Loads the model information from a JSON.
   */
  void fromJson(Map json)
  {
    String model = json[_modelName];

    int index;

    switch (model)
    {
      case _cubeModelName     : index = _cubeModelIndex;     break;
      case _sphereModelName   : index = _sphereModelIndex;   break;
      case _planeModelName    : index = _planeModelIndex;    break;
      case _cylinderModelName : index = _cylinderModelIndex; break;
      default: index = _customModelIndex;
    }

    _showSelectedModel(index);
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether a custom model is being used
  bool get isCustomModel => _selectedModel == _customModelIndex;

  /**
   * Gets the location of the mesh file.
   *
   * Returns an empty string if a custom model is being used.
   */
  String get modelPath
  {
    switch (_selectedModel)
    {
      case _cubeModelIndex    : return _cubeModelPath;
      case _sphereModelIndex  : return _sphereModelPath;
      case _planeModelIndex   : return _planeModelPath;
      case _cylinderModelIndex: return _cylinderModelPath;
      default:                  return '';
    }
  }

  //---------------------------------------------------------------------
  // Methods
  //---------------------------------------------------------------------

  /**
   * Shows what model is currently selected.
   */
  void _showSelectedModel(int index)
  {
    _selectedModel = index;

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
