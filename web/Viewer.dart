library viewer;

import 'dart:html';
import 'dart:json';
import 'dart:math' as Math;
import 'dart:isolate';

import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';

//---------------------------------------------------------------------
// Source files
//---------------------------------------------------------------------

part 'application/frame_counter.dart';
part 'application/game.dart';
part 'application/shader_defaults.dart';
part 'ui/compile_log.dart';
part 'ui/element_names.dart';
part 'ui/modal_dialog.dart';
part 'ui/model_selection.dart';
part 'ui/new_file.dart';
part 'ui/renderer_selection.dart';
part 'ui/source_editor.dart';
part 'ui/tabbed_element.dart';
part 'ui/tool_tip.dart';
part 'ui/texture_selection.dart';
part 'ui/uniform_selection.dart';
part 'workspace/application_file_system.dart';
part 'workspace/workspace.dart';

/// Instance of the [Viewer] class.
Viewer _viewer;
/// Instance of the [FrameCounter] class.
FrameCounter _counter;

class Viewer
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Serialization name for the renderer state.
  static const String _rendererStateName = 'rendererState';
  /**
   * The delay before showing the file system dialog.
   *
   * Assume that after x amount of time that the request file system
   * dialog has not been accepted.
   */
  static const int _fileSystemDialogDelay = 10000;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [ApplicationFilesystem].
  ApplicationFileSystem _fileSystem;
  /// The current [Workspace].
  Workspace _currentWorkspace;
  /// UI for the model tab.
  ModelSelection _modelSelection;
  /// UI for the textures tab.
  TextureSelection _textureSelection;
  /// Source code editor for the vertex shader.
  SourceEditor _vertexShaderEditor;
  /// Source code editor for the fragment shader.
  SourceEditor _fragmentShaderEditor;
  /// UI for the uniforms tab.
  UniformSelection _uniformSelection;
  /// UI for the renderer tab.
  RendererSelection _rendererSelection;
  /// The [CompileLog] for the shader program.
  CompileLog _compileLog;
  /// The [ModalDialog] for the loading screen.
  ModalDialog _loadingScreen;
  /// The [ModalDialog] for the filesystem dialog.
  ModalDialog _fileSystemDialog;
  /// The [ModalDialog] for the save dialog.
  SaveDialog _saveDialog;
  /// The [ModalDialog] for the loading dialog.
  LoadDialog _loadDialog;
  /// The [ModalDialog] for the about dialog.
  SimpleModalDialog _aboutDialog;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [Viewer] class.
   */
  Viewer()
  {
    _setupDialogs();
    _setupMenuBar();
    _setupUI();
    _setupUITab();

    // Create the filesystem
    // Do this last as there is a callback involved for the
    // filesystem that will modify the UI.
    _fileSystem = new ApplicationFileSystem(_onFileSystemReady);
  }

  /**
   * Initialzies the UI elements.
   */
  void _setupUI()
  {
    // Attach to the model UI
    _modelSelection = new ModelSelection();
    _modelSelection.modelChangedCallback = _onModelChanged;
    _modelSelection.modelLoadedCallback = _onModelLoaded;

    // Attach to the texture UI
    _textureSelection = new TextureSelection();
    _textureSelection.textureCallback = _onTextureChanged;
    _textureSelection.samplerStateCallback = _onSamplerStateChanged;

    // Attach to the vertex shader editor
    _vertexShaderEditor = new SourceEditor('#vertex_shader_source', '#vertex_shader_code_lines');
    _vertexShaderEditor.sourceCallback = _onVertexShaderChanged;

    // Attach to the fragment shader editor
    _fragmentShaderEditor = new SourceEditor('#fragment_shader_source', '#fragment_shader_code_lines');
    _fragmentShaderEditor.sourceCallback = _onFragmentShaderChanged;

    // Attach to the uniform UI
    _uniformSelection = new UniformSelection();
    _uniformSelection.changeCallback = _onUniformsChanged;

    // Attach to the renderer UI
    _rendererSelection = new RendererSelection();
    _rendererSelection.blendStateCallback = _onBlendStateChanged;
    _rendererSelection.depthStateCallback = _onDepthStateChanged;
    _rendererSelection.rasterizerStateCallback = _onRasterizerStateChanged;

    // Attach to the compile log
    TabbedElement element = new TabbedElement();
    element.addTab('#error_tab', '#error_list');
    element.addTab('#warning_tab', '#warning_list');

    _compileLog = new CompileLog();
  }

  /**
   * Initializes the menu bar.
   */
  void _setupMenuBar()
  {
    DivElement newFileButton = query(_ElementNames.newFileButtonName);
    newFileButton.on.click.add((_) {
      newWorkspace();
    });

    DivElement loadFileButton = query(_ElementNames.loadFileButtonName);
    loadFileButton.on.click.add((_) {
      _loadDialog.show();
    });

    DivElement saveFileButton = query(_ElementNames.saveFileButtonName);
    saveFileButton.on.click.add((_) {
      saveWorkspace();
    });

    DivElement saveAsFileButton = query(_ElementNames.saveAsFileButtonName);
    saveAsFileButton.on.click.add((_) {
      _saveDialog.show();
    });

    DivElement aboutButton = query(_ElementNames.aboutButtonName);
    aboutButton.on.click.add((_) {
      _aboutDialog.show();
    });

    DivElement fullscreenButton = query(_ElementNames.fullscreenButtonName);
    fullscreenButton.on.click.add((_) {
      Game.instance.fullscreen = true;
    });
  }

  /**
   * Initializes the UI tabs.
   */
  void _setupUITab()
  {
    TabbedElement element = new TabbedElement();
    element.addTab(_ElementNames.modelTabName, _ElementNames.modelAreaName);
    element.addTab(_ElementNames.textureTabName, _ElementNames.textureAreaName);
    element.addTab(_ElementNames.vertexShaderTabName, _ElementNames.vertexShaderAreaName);
    element.addTab(_ElementNames.fragmentShaderTabName, _ElementNames.fragmentShaderAreaName);
    element.addTab(_ElementNames.variablesTabName, _ElementNames.variablesAreaName);
    element.addTab(_ElementNames.rendererTabName, _ElementNames.rendererAreaName);
  }

  /**
   * Initializes the dialogs.
   */
  void _setupDialogs()
  {
    _loadingScreen = new ModalDialog(_ElementNames.loadingScreenName);
    _fileSystemDialog = new ModalDialog(_ElementNames.filesystemDialogName);
    _aboutDialog = new SimpleModalDialog(_ElementNames.aboutDialogName);

    // Create the callback for displaying the file system dialog
    Timer timer = new Timer(_fileSystemDialogDelay, (_) {
      _onFileSystemTimeout();
    });
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Resets the state of the application.
   */
  void newWorkspace()
  {
    // Clear the temporary file system
    _currentWorkspace = _fileSystem.tempWorkspace;
    _currentWorkspace.clear();

    // Load the state
    deserialize(JSON.parse(_newFileState));

    // Set the shader program
    _vertexShaderEditor.source = _defaultVertexSource;
    _fragmentShaderEditor.source = _defaultFragmentSource;

    // Set the shader program
    _updateWorkspace();
  }

  /**
   * Loads the state of the application.
   */
  void loadWorkspace(String name)
  {
    _fileSystem.loadWorkspace(name).then((workspace) {
      _currentWorkspace = workspace;

      _currentWorkspace.loadVertexShader().then((vertexSource) {
        _vertexShaderEditor.source = vertexSource;

        _currentWorkspace.loadFragmentShader().then((fragmentSource) {
          _fragmentShaderEditor.source = fragmentSource;

          _currentWorkspace.loadState().then((state) {
            deserialize(state);

            _updateWorkspace();
          });
        });
      });
    });
  }

  /**
   * Saves the state of the application.
   */
  void saveWorkspace()
  {
    // Check to see if the current workspace is the temporary one.
    if (_currentWorkspace == _fileSystem.tempWorkspace)
    {
      _saveDialog.show();
    }
    else
    {
      _saveWorkspaceState();
    }
  }

  /**
   * Saves the state of the application.
   *
   * Creates a new workspace with the given [name].
   */
  void saveWorkspaceAs(String name)
  {
    _fileSystem.copyWorkspace(_currentWorkspace, name).then((workspace) {
      // Get the paths to the workspaces
      String originalPath = _currentWorkspace.path;
      String copyPath = workspace.path;

      // Set the workspace as the new one
      _currentWorkspace = workspace;

      // Update the asset paths
      for (TextureUnit textureUnit in _textureSelection.textureUnits)
      {
        String texturePath = textureUnit.texture;
        textureUnit.texture = texturePath.replaceAll(originalPath, copyPath);
      }

      _saveWorkspaceState();
    });
  }

  /**
   * Saves the state of the application.
   */
  void _saveWorkspaceState()
  {
    Map values = _serialize();
    String state = JSON.stringify(values);

    _currentWorkspace.saveState(state)
      .chain((_) => _currentWorkspace.saveVertexShader(_vertexShaderEditor.source))
      .chain((_) => _currentWorkspace.saveFragmentShader(_fragmentShaderEditor.source))
      .then ((_) {
        print('Worspace saved');
      });
  }

  /**
   * Serializes the state of the application.
   */
  Map _serialize()
  {
    Map data = new Map();

    // Append the model data to the map
    Map modelData = _modelSelection.toJson();

    modelData.forEach((key, value) {
      data[key] = value;
    });

    // Append the texture data to the map
    Map textureData = _textureSelection.toJson();

    textureData.forEach((key, value) {
      data[key] = value;
    });

    // Append the renderer state to the map
    Map rendererData = _rendererSelection.toJson();

    rendererData.forEach((key, value) {
      data[key] = value;
    });

    return data;
  }

  /**
   * Deserializes the state of the application.
   */
  void deserialize(Map data)
  {
    _modelSelection.fromJson(data);
    _rendererSelection.fromJson(data);
    _textureSelection.fromJson(data);
  }

  /**
   * Updates the workspace.
   *
   * Called after a workspace is loaded.
   */
  void _updateWorkspace()
  {
    Game game = Game.instance;

    // Update the model
    String modelPath = _modelSelection.modelPath;

    if (modelPath.isEmpty)
    {
      // Load from workspace
    }

    game.mesh = modelPath;

    // Update the textures
    List<TextureUnit> textureUnits = _textureSelection.textureUnits;
    int length = textureUnits.length;

    for (int i = 0; i < length; ++i)
    {
      TextureUnit textureUnit = textureUnits[i];

      game.setTextureAt(i, textureUnit.texture);
      game.setSamplerStateAt(i, textureUnit.samplerState);
    }

    // Update the shaders
    game.setVertexSource(_vertexShaderEditor.source);
    game.setFragmentSource(_fragmentShaderEditor.source);

    _onShaderProgramChanged();
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when the filesystem is ready.
   */
  void _onFileSystemReady()
  {
    if (_loadingScreen.visible)
    {
      _loadingScreen.hide();
    }

    if (_fileSystemDialog.visible)
    {
      _fileSystemDialog.hide();
    }

    _saveDialog = new SaveDialog(_ElementNames.saveDialogName, _fileSystem);
    _saveDialog.submitCallback = _onSaveAs;

    _loadDialog = new LoadDialog(_ElementNames.loadDialogName, _fileSystem);
    _loadDialog.submitCallback = _onLoad;

    newWorkspace();
  }

  /**
   * Callback for when the request dialog.
   */
  void _onFileSystemTimeout()
  {
    if (_loadingScreen.visible)
    {
      _loadingScreen.hide();
      _fileSystemDialog.show();
    }
  }

  /**
   * Callback for when a workspace is saved.
   */
  void _onSaveAs(String name)
  {
    _saveDialog.hide();

    saveWorkspaceAs(name);
  }

  /**
   * Callback for when a workspace is loaded.
   */
  void _onLoad(String name)
  {
    _loadDialog.hide();

    loadWorkspace(name);
  }

  /**
   * Callback for when a model is changed.
   */
  void _onModelChanged(String url)
  {
    Game.instance.mesh = url;
  }

  /**
   * Callback for when a model is loaded.
   */
  void _onModelLoaded(File file)
  {
    String extension = _getFileExtension(file);

    if (extension == '.mesh')
    {
      _currentWorkspace.saveModel(file).then((value) {
        print('Model changed $value');

        // Display the new model
        Game.instance.mesh = value;
      });
    }
    else
    {
      print('Connecting to server');
      WebSocket connection = new WebSocket('ws://localhost:8000/ws');

      connection.on.open.add((_) {
        print('Connected to server');

        connection.send(file.name);
        connection.send(file);
      });

      connection.on.message.add((messageEvent) {
        _currentWorkspace.saveModelFromString(messageEvent.data).then((value) {
          print('Model changed $value');

          // Display the new model
          Game.instance.mesh = value;

          // Close the connection
          connection.close();
        });
      });
    }
  }

  /**
   * Callback for when a [Texture] is changed.
   */
  void _onTextureChanged(File file, int textureUnit)
  {
    _currentWorkspace.saveTexture(file, textureUnit).then((value) {
      print('Texture changed $value');

      // Display the new texture
      _textureSelection.textureUnits[textureUnit].texture = value;
      Game.instance.setTextureAt(textureUnit, value);
    });
  }

  /**
   * Calback for when a [SamplerState] is changed.
   */
  void _onSamplerStateChanged(String values, int textureUnit)
  {
    Game.instance.setSamplerStateAt(textureUnit, values);
  }

  /**
   * Callback for when the vertex shader is modified.
   */
  void _onVertexShaderChanged(String value)
  {
    Game.instance.setVertexSource(value);

    _onShaderProgramChanged();
  }

  /**
   * Callback for when the fragment shader is modified.
   */
  void _onFragmentShaderChanged(String value)
  {
    Game.instance.setFragmentSource(value);

    _onShaderProgramChanged();
  }

  /**
   * Callback for when the shader program is modified.
   */
  void _onShaderProgramChanged()
  {
    Game game = Game.instance;
    _compileLog.clear();
    _vertexShaderEditor.clearErrors();
    _fragmentShaderEditor.clearErrors();

    if (game.isProgramValid)
    {
      // Update the shader uniforms
      _uniformSelection.uniformTypes = Game.instance.uniforms;
    }
    else
    {
      // Update the compile log
      _compileLog.addToLog('Vertex', game.vertexShaderLog);
      _compileLog.addToLog('Fragment', game.fragmentShaderLog);

      // Show errors/warnings in the editor
      _vertexShaderEditor.setErrorsAt(_compileLog.vertexShaderErrorLines);
      _vertexShaderEditor.setWarningsAt(_compileLog.vertexShaderWarningLines);

      _fragmentShaderEditor.setErrorsAt(_compileLog.fragmentShaderErrorLines);
      _fragmentShaderEditor.setWarningsAt(_compileLog.fragmentShaderWarningLines);
    }
  }

  /**
   * Callback for when the uniforms are changed.
   */
  void _onUniformsChanged(Map<String, Map<String, dynamic>> values)
  {
    print('uniforms changed');
    Game.instance.uniformValues = values;
  }

  /**
   * Callback when the rasterizer state is changed.
   */
  void _onRasterizerStateChanged(String properties)
  {
    Game.instance.setRasterizerStateProperties(properties);
  }

  /**
   * Callback when the depth state is changed.
   */
  void _onDepthStateChanged(String properties)
  {
    Game.instance.setDepthStateProperties(properties);
  }

  /**
   * Callback when the blend state is changed.
   */
  void _onBlendStateChanged(String properties)
  {
    Game.instance.setBlendStateProperties(properties);
  }

  //---------------------------------------------------------------------
  // Static methods
  //---------------------------------------------------------------------

  static String _getFileExtension(File file)
  {
    String fileName = file.name;

    return fileName.substring(fileName.lastIndexOf('.'));
  }
}

/**
 * Update function for the application.
 *
 * The current [time] is passed in.
 */
void _onUpdate(double time)
{
  _counter.update(time);
  Game.onUpdate(time);

  // For the animation to continue the function
  // needs to set itself again
  window.requestAnimationFrame(_onUpdate);
}

/**
 * Main entrypoint to the application.
 */
void main()
{
  _viewer = new Viewer();

  // Initialize the WebGL side
  Game.onInitialize();
  _counter = new FrameCounter('#frame_counter');

  Game.instance.setVertexSource(_defaultVertexSource);
  Game.instance.setFragmentSource(_defaultFragmentSource);

  window.requestAnimationFrame(_onUpdate);
}
