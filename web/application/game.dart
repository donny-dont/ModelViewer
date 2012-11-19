part of viewer;

class Game
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Singleton holding the [Game] instance.
  static Game _gameInstance;
  /// Move camera to the left.
  static const int _keyCodeA = 65;
  /// Move camera to the right.
  static const int _keyCodeD = 68;
  /// Move camera backwards.
  static const int _keyCodeS = 83;
  /// Move camera forward.
  static const int _keyCodeW = 87;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  // CanvasElement
  CanvasElement _canvas;
  /// Spectre graphics device.
  GraphicsDevice _graphicsDevice;
  /// Immediate rendering context.
  GraphicsContext _context;

  /**
   * Resource handler for the game.
   *
   * All resources, texture, mesh, shader, etc, that require loading should
   * go through the resource handler. This ensures that resources are not
   * loaded redundantly.
   */
  ResourceManager _resourceManager;
  /// Handle to the viewport.
  int _viewport;

  //---------------------------------------------------------------------
  // Animation variables
  //---------------------------------------------------------------------

  /// Clear color for the rendering.
  vec3 _color;
  /// Direction to modify the color.
  vec3 _direction;
  /// Random number generator
  Math.Random _randomGenerator;
  /// The time of the last frame
  double _lastFrameTime;
  /// The angle to rotate by
  double _angle;

  //---------------------------------------------------------------------
  // Transform variables
  //---------------------------------------------------------------------

  /// Camera
  Camera _camera;
  /// Camera controller
  MouseKeyboardCameraController _cameraController;

  /// Transformation for the mesh.
  mat4 _modelMatrix;
  /// A typed array containing the transformation.
  Float32Array _modelMatrixArray;
  /**
   * A [Float32Array] containing the view/projection matrix.
   *
   * Contains the view, which is generated from the camera's position,
   * direction, and up vector, and the projection, which is generated
   * from the view frustum.
   *
   * The camera is stationary in this lesson so an associated mat4
   * is not needed.
   */
  Float32Array _viewProjectitonMatrixArray;

  //---------------------------------------------------------------------
  // Buffer variables
  //---------------------------------------------------------------------

  /**
   * A handle to the vertex buffer for the mesh.
   */
  int _meshVertexBuffer;
  /**
   * A handle to the vertex attributes to use.
   *
   * The vertex attributes specify how the vertices are laid out
   * in memory. A vertex buffer can have multiple attributes interleaved
   * within it.
   */
  int _meshInputLayout;
  /**
   * A handle to the index buffer.
   *
   * The index buffer contains indices into the vertex buffer to use
   * when drawing. This allows for vertex data to be repeated during drawing.
   */
  int _meshIndexBuffer;
  /// The number of indices in the buffer
  int _meshIndexCount;
  /// Handle to the texture to use.
  int _texture;

  //---------------------------------------------------------------------
  // Shader variables
  //---------------------------------------------------------------------

  /**
   * A handle to the vertex shader to use.
   *
   * A vertex shader is a program that runs once per vertex.
   * It is run first within the pipeline.
   */
  int _vertexShader;

  /**
   * A handle to the fragment shader to use.
   *
   * A fragment shader is a program that runs once per pixel.
   * It is run after the vertex shader within the pipeline.
   */
  int _fragmentShader;

  /**
   * A handle to the shader program to use.
   *
   * A shader program is the result of linking together
   * vertex and fragment shaders. By setting it the rendering
   * pipeline is run through the vertex and fragment shader
   * code.
   */
  int _shaderProgram;
  /**
   * A handle to the user supplied shader program.
   */
  int _userShaderProgram;
  /**
   * A handle to the fallback shader program to use.
   */
  int _fallbackShaderProgram;

  //---------------------------------------------------------------------
  // State variables
  //---------------------------------------------------------------------

  /// Contains blend state for the device.
  int _blendState;
  /// Contains depth state for the device.
  int _depthState;
  /// Contains rasterization state for the device.
  int _rasterizerState;
  /// Contains sampler state for a texture.
  int _samplerState;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [Game] class.
   *
   * The [id] specifies the canvas element to use.
   */
  Game(String id)
  {
    CanvasElement canvas = document.query(id) as CanvasElement;
    _canvas = canvas;

    assert(canvas != null);
    WebGLRenderingContext gl = canvas.getContext('experimental-webgl');

    assert(gl != null);

    // Initialize Spectre
    initSpectre();

    // Setup the Spectre device
    _graphicsDevice = new GraphicsDevice(gl);
    _context = _graphicsDevice.context;

    // Setup the resource manager
    _resourceManager = new ResourceManager();

    // Create the viewport
    var viewportProperties = {
      'x': 0,
      'y': 0,
      'width': canvas.width,
      'height': canvas.height
    } ;

    // Create the viewport
    _viewport = _graphicsDevice.createViewport('view', viewportProperties);

    // Setup the clear color
    _color = new vec3(0.0, 0.0, 0.0);
    _direction = new vec3(1.0, 1.0, 1.0);
    _randomGenerator = new Math.Random();
    _lastFrameTime = 0.0;
    _angle = 0.0;

    // Create camera
    _camera = new Camera();
    // Set camera aspect ratio
    _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
    // Create a mouse keyboard camera controller
    _cameraController = new MouseKeyboardCameraController();
    // Bind the controls for the camera
    _bindControls();

    // Create graphics resources
    _createTransforms();
    _createShaders();
    _createState();
    _createBuffers();
  }

  /**
   * Responds to key down events
   */
  void _keyDownHandler(KeyboardEvent event) {
    if (!_pointerLocked)
    {
      return;
    }

    switch (event.keyCode)
    {
      case _keyCodeA:
        _cameraController.strafeLeft = true;
      break;
      case _keyCodeD:
        _cameraController.strafeRight = true;
      break;
      case _keyCodeS:
        _cameraController.backward = true;
      break;
      case _keyCodeW:
        _cameraController.forward = true;
      break;
    }
  }

  /**
   * Responds to key up events
   */
  void _keyUpHandler(KeyboardEvent event) {
    switch (event.keyCode)
    {
      case _keyCodeA:
        _cameraController.strafeLeft = false;
      break;
      case _keyCodeD:
        _cameraController.strafeRight = false;
      break;
      case _keyCodeS:
        _cameraController.backward = false;
      break;
      case _keyCodeW:
        _cameraController.forward = false;
      break;
    }
  }

  /**
   * Responds to mouse move events
   */
  void _mouseMoveHandler(MouseEvent event) {
    if (_pointerLocked)
    {
      _cameraController.accumDX += event.webkitMovementX;
      _cameraController.accumDY += event.webkitMovementY;
    }
  }

  /**
   * Respond to pointer lock state changes.
   */
  void _pointerLockChange(Event event) {
    if (_pointerLocked)
    {
      print('Canvas owns pointer.');
    }
    else
    {
      print('Canvas does not own pointer.');
    }
  }

  /**
   * Respond to clicks on the canvas
   */
  void _canvasClicked(Event event) {
    // Request pointer lock
    _canvas.webkitRequestPointerLock();
  }

  /**
   * Bind the keyboard and mouse to the camera controller
   */
  void _bindControls() {
    _canvas.on.click.add(_canvasClicked);
    document.on.pointerLockChange.add(_pointerLockChange);
    document.on.keyDown.add(_keyDownHandler);
    document.on.keyUp.add(_keyUpHandler);
    document.on.mouseMove.add(_mouseMoveHandler);
  }

  /**
   * Setup the camera transform
   */
  void _updateCameraTransform() {
    mat4 viewProjectionMatrix = _camera.projectionMatrix;
    mat4 viewMatrix = _camera.lookAtMatrix;
    viewProjectionMatrix.multiply(viewMatrix);
    // Copy into
    viewProjectionMatrix.copyIntoArray(_viewProjectitonMatrixArray);
  }

  /**
   * Create the transforms.
   */
  void _createTransforms()
  {
    // Compute the aspect ratio
    Viewport viewport = _graphicsDevice.getDeviceChild(_viewport);
    double aspectRatio = viewport.width / viewport.height;

    // The camera is located -2.5 units along the Z axis.
    _camera.position = new vec3.raw(0.0, 0.0, -2.5);
    // The camera is pointed at the origin.
    _camera.focusPosition = new vec3.raw(0.0, 0.0, 0.0);

    _viewProjectitonMatrixArray = new Float32Array(16);
    _updateCameraTransform();

    // Create the model matrix
    // Center it at 0.0, 0.0, 0.0
    _modelMatrix = new mat4.identity();

    _modelMatrixArray = new Float32Array(16);
  }

  /**
   * Create the shaders to use for rendering.
   */
  void _createShaders()
  {
    // Create the fallback shader program
    _fallbackShaderProgram = _graphicsDevice.createShaderProgram('Fallback Program', {});

    int fallbackVertexShader = _graphicsDevice.createVertexShader('Fallback Vertex Shader', {});
    _context.compileShader(fallbackVertexShader, _fallbackVertexShader);

    int fallbackFragmentShader = _graphicsDevice.createFragmentShader('Fallback Fragment Shader', {});
    _context.compileShader(fallbackFragmentShader, _fallbackFragmentShader);

    Map fallbackShaderProps = {
      'VertexProgram': fallbackVertexShader,
      'FragmentProgram': fallbackFragmentShader
    } ;

    _graphicsDevice.configureDeviceChild(_fallbackShaderProgram, fallbackShaderProps);

    // Create the user defined shader program
    _userShaderProgram = _graphicsDevice.createShaderProgram('User Program', {});

    _vertexShader = _graphicsDevice.createVertexShader('User Vertex Shader', {});
    _fragmentShader = _graphicsDevice.createFragmentShader('User Fragment Shader', {});

    Map userShaderProps = {
      'VertexProgram': _vertexShader,
      'FragmentProgram': _fragmentShader
    } ;

    _graphicsDevice.configureDeviceChild(_userShaderProgram, userShaderProps);

    // By default use the fallback
    _shaderProgram = _fallbackShaderProgram;
  }

  /**
   * Create all the rendering state.
   */
  void _createState()
  {
    // Create the blend state
    Map blendStateProperties = {
      'blendEnable':true,
      'blendSourceColorFunc': BlendState.BlendSourceShaderAlpha,
      'blendDestColorFunc': BlendState.BlendSourceShaderInverseAlpha,
      'blendSourceAlphaFunc': BlendState.BlendSourceShaderAlpha,
      'blendDestAlphaFunc': BlendState.BlendSourceShaderInverseAlpha
    };

    _blendState = _graphicsDevice.createBlendState('Blend State', blendStateProperties);

    // Create the depth state
    Map depthStateProperties = {
      'depthTestEnabled': true,
      'depthComparisonOp': DepthState.DepthComparisonOpLess
    };

    _depthState = _graphicsDevice.createDepthState('Depth State', depthStateProperties);

    // Create the sampler state
    Map samplerStateProperties = { };

    _samplerState = _graphicsDevice.createSamplerState('Sampler State', samplerStateProperties);

    // Create the rasterizer state
    Map rasterizerStateProperties = {
      'cullEnabled': true,
      'cullMode': RasterizerState.CullBack,
      'cullFrontFace': RasterizerState.FrontCCW
    };

    _rasterizerState = _graphicsDevice.createRasterizerState('Rasterizer State', rasterizerStateProperties);
  }

  /**
   * Create all the buffer data.
   */
  void _createBuffers()
  {
    // The vertex and index buffer will not be modified each frame.
    // So mark it as static. This does not mean the contents can't be
    // changed, but the driver shouldn't expect it to happen often
    // and can optimize based on this assumption
    Map staticBufferUsage = { 'usage': 'static' };

    // Create the vertex buffer
    _meshVertexBuffer = _graphicsDevice.createVertexBuffer('Vertex Buffer', staticBufferUsage);
    _meshInputLayout = _graphicsDevice.createInputLayout('Input Layout', {});

    // Create the index buffer
    _meshIndexBuffer = _graphicsDevice.createIndexBuffer('Index Buffer', staticBufferUsage);
    _meshIndexCount = 0;

    // Create the texture
    Map textureUsage = {
      'textureFormat': Texture.TextureFormatRGB,
      'pixelFormat': Texture.PixelFormatUnsignedByte
    };

    _texture = _graphicsDevice.createTexture2D('Texture', textureUsage);
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /**
   * Update method for the [Game].
   *
   * All game logic should be updated within this method.
   * Any animation should be based upon the current [time].
   */
  void update(double time)
  {
    // Get the change in time
    double dt = (time - _lastFrameTime) * 0.001;
    _lastFrameTime = time;

    // Update the camera
    _cameraController.UpdateCamera(dt, _camera);
    _updateCameraTransform();

    // Rotate the model
    double angle = dt * Math.PI;

    mat4 rotation = new mat4.rotationX(angle);
    _modelMatrix.multiply(rotation);

    _modelMatrix.copyIntoArray(_modelMatrixArray);

    for (int i = 0; i < 3; ++i)
    {
      // Add a random difference
      _color[i] += _direction[i] * (_randomGenerator.nextDouble() * 0.01);

      // Colors range from [0, 1]
      // Change direction when necessary
      if (_color[i] > 1.0)
      {
        _color[i] = 1.0;
        _direction[i] = -1.0;
      }
      else if (_color[i] < 0.0)
      {
        _color[i] = 0.0;
        _direction[i] = 1.0;
      }
    }
  }

  /**
   * Draw method for the [Game].
   *
   * All rendering logic should go here.
   */
  void draw()
  {
    // Clear the buffers
    _context.clearColorBuffer(
      _color.x,
      _color.y,
      _color.z,
      1.0
    );
    _context.clearDepthBuffer(1.0);
    _context.reset();

    // Set the viewport
    _context.setViewport(_viewport);

    // Set associated state
    _context.setBlendState(_blendState);
    _context.setRasterizerState(_rasterizerState);
    _context.setDepthState(_depthState);

    // Set the shader program
    _context.setShaderProgram(_shaderProgram);
    _context.setUniformMatrix4('objectTransform', _modelMatrixArray);
    _context.setUniformMatrix4('cameraTransform', _viewProjectitonMatrixArray);

    // Set the texture
    _context.setTextures(0, [_texture]);
    _context.setSamplers(0, [_samplerState]);

    // Set the vertex/index buffers
    _context.setInputLayout(_meshInputLayout);
    _context.setVertexBuffers(0, [_meshVertexBuffer]);
    _context.setIndexBuffer(_meshIndexBuffer);

    // Draw the mesh
    _context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    _context.drawIndexed(_meshIndexCount, 0);
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Retrieves the instance of [Game].
  static Game get instance => _gameInstance;
  /// Whether the canvas has control of the pointer.
  bool get _pointerLocked => _canvas == document.webkitPointerLockElement;

  /**
   * Sets the mesh to display.
   */
  set mesh(String value)
  {
    int meshResource = _resourceManager.registerResource(value);

    _resourceManager.addEventCallback(meshResource, ResourceEvents.TypeUpdate, (type, resource) {
      MeshResource mesh = resource;

      // Get the description of the layout
      var elements = [
        InputLayoutHelper.inputElementDescriptionFromMesh(new InputLayoutDescription('vPosition', 0, 'POSITION' ), mesh),
        InputLayoutHelper.inputElementDescriptionFromMesh(new InputLayoutDescription('vTexCoord', 0, 'TEXCOORD0'), mesh)
      ];

      _graphicsDevice.configureDeviceChild(_meshInputLayout, { 'elements': elements });
      _graphicsDevice.configureDeviceChild(_meshInputLayout, { 'shaderProgram': _shaderProgram });

      // Get the number of indices
      _meshIndexCount = mesh.numIndices;

      // Update the contents of the buffer
      _context.updateBuffer(_meshVertexBuffer, mesh.vertexArray);
      _context.updateBuffer(_meshIndexBuffer, mesh.indexArray);
    });

    _resourceManager.loadResource(meshResource);
  }

  /**
   * Sets the texture to use on the mesh.
   */
  set texture(String value)
  {
    int textureResource = _resourceManager.registerResource(value);

    _resourceManager.addEventCallback(textureResource, ResourceEvents.TypeUpdate, (type, resource) {
      print('texture loaded: ${_texture}');
      _context.updateTexture2DFromResource(_texture, textureResource, _resourceManager);
      _context.generateMipmap(_texture);
    });

    _resourceManager.loadResource(textureResource);
  }

  /**
   * Reconfigures the rasterizer state for the rendering.
   */
  void setRasterizerStateProperties(String props)
  {
    _graphicsDevice.configureDeviceChild(_rasterizerState, props);
  }

  /**
   * Reconfigures the depth state for the rendering.
   */
  void setDepthStateProperties(String props)
  {
    _graphicsDevice.configureDeviceChild(_depthState, props);
  }

  /**
   * Reconfigures the blend state for the rendering.
   */
  void setBlendStateProperties(String props)
  {
    _graphicsDevice.configureDeviceChild(_blendState, props);
  }

  /**
   * Check if the user defined program is valid.
   */
  bool get isProgramValid
  {
    // Query if the shaders are valid
    // Check for compilation errors
    VertexShader vertexShader = _graphicsDevice.getDeviceChild(_vertexShader);
    if (!vertexShader.compiled)
      return false;

    FragmentShader fragmentShader = _graphicsDevice.getDeviceChild(_fragmentShader);
    if (!fragmentShader.compiled)
      return false;

    // Query if the program is valid
    // Check for linker errors
    ShaderProgram shaderProgram = _graphicsDevice.getDeviceChild(_userShaderProgram);

    return shaderProgram.linked;
  }

  /**
   * Gets the vertex shader's compilation.
   */
  String get vertexShaderLog
  {
    VertexShader vertexShader = _graphicsDevice.getDeviceChild(_vertexShader);
    return vertexShader.log;
  }

  /**
   * Gets the fragment shader's compilation log.
   */
  String get fragmentShaderLog
  {
    FragmentShader fragmentShader = _graphicsDevice.getDeviceChild(_fragmentShader);
    return fragmentShader.log;
  }

  /**
   * Reconfigure the vertex shader for the rendering.
   */
  void setVertexSource(String source)
  {
    _context.compileShader(_vertexShader, source);

    ShaderProgram program = _graphicsDevice.getDeviceChild(_userShaderProgram);
    program.link();

    _shaderProgram = (isProgramValid) ? _userShaderProgram : _fallbackShaderProgram;
  }

  /**
   * Reconfigure the fragment shader for the rendering.
   */
  void setFragmentSource(String source)
  {
    _context.compileShader(_fragmentShader, source);

    ShaderProgram program = _graphicsDevice.getDeviceChild(_userShaderProgram);
    program.link();

    _shaderProgram = (isProgramValid) ? _userShaderProgram : _fallbackShaderProgram;
  }

  //---------------------------------------------------------------------
  // Static methods
  //---------------------------------------------------------------------

  /**
   * Initializes the [Game] instance.
   */
  static void onInitialize()
  {
    _gameInstance = new Game('#webgl_host');

    // Set the mesh and associated texture
    _gameInstance.texture = 'web/resources/textures/dart_tex_alpha.png';
    _gameInstance.mesh = 'web/resources/meshes/cube.mesh';
  }

  /**
   * Update loop for the [Game].
   *
   * The current [time] is passed in.
   */
  static void onUpdate(double time)
  {
    _gameInstance.update(time);
    _gameInstance.draw();
  }
}
