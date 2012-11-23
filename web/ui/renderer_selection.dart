part of viewer;

/// Callback type for when the value is changed
typedef void StateEvent(String values);

/**
 * UI for changing the state of the renderer.
 */
class RendererSelection
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Serialization name for the blend state
  static const String _blendStateName = 'blendState';
  /// Serialization name for the depth state
  static const String _depthStateName = 'depthState';
  /// Serialization name for the rasterizer state
  static const String _rasterizerStateName = 'rasterizerState';

  static const String _rasterizerStateEnabledId = '#rasterizer_state_enabled';
  static const String _rasterizerStateCullModeId = '#rasterizer_cull_mode';
  static const String _rasterizerStateFrontFaceId = '#rasterizer_front_face';

  static const String _depthStateEnabledId = '#depth_state_enabled';
  static const String _depthStateWriteEnabledId = '#depth_write_enabled';
  static const String _depthStateComparisonId = '#depth_comparison';

  static const String _blendStateEnabledId = '#blend_state_enabled';
  static const String _blendStateSourceColorId = '#source_color_function';
  static const String _blendStateDestinationColorId = '#destination_color_function';
  static const String _blendStateSourceAlphaId = '#source_alpha_function';
  static const String _blendStateDestinationAlphaId = '#destination_alpha_function';
  static const String _blendStateColorOperationId = '#blend_color_operation';
  static const String _blendStateAlphaOperationId = '#blend_alpha_operation';
  static const String _blendStateWriteRedId = '#write_red_enabled';
  static const String _blendStateWriteGreenId = '#write_green_enabled';
  static const String _blendStateWriteBlueId = '#write_blue_enabled';
  static const String _blendStateWriteAlphaId = '#write_alpha_enabled';

  static const String _clearColorAnimationEnabledId = '#clear_color_animation_enabled';

  //---------------------------------------------------------------------
  // Rasterizer state member variables
  //---------------------------------------------------------------------

  /// Callback for when the [RasterizerState] changes.
  StateEvent rasterizerStateCallback;
  /// Whether the rasterizer state is enabled.
  InputElement _rasterizerStateEnabledElement;
  /// Culling mode to use.
  SelectElement _rasterizerStateCullModeElement;
  /// The front face for triangles.
  SelectElement _rasterizerStateFrontFaceElement;

  //---------------------------------------------------------------------
  // Depth state member variables
  //---------------------------------------------------------------------

  /// Callback for when the [DepthState] changes.
  StateEvent depthStateCallback;
  /// Whether the depth state is enabled.
  InputElement _depthStateEnabledElement;
  /// Whether writing to the depth buffer is enabled.
  InputElement _depthStateWriteEnabledElement;
  /// Comparison operation for the depth buffer.
  SelectElement _depthStateComparisonElement;

  //---------------------------------------------------------------------
  // Blend state member variables
  //---------------------------------------------------------------------

  /// Callback for when the [BlendState] changes.
  StateEvent blendStateCallback;
  /// Whether the blend state is enabled.
  InputElement _blendStateEnabledElement;
  /// Source color function.
  SelectElement _blendStateSourceColorElement;
  /// Destination color function.
  SelectElement _blendStateDestinationColorElement;
  /// Source alpha function.
  SelectElement _blendSourceAlphaElement;
  /// Destination alpha function.
  SelectElement _blendDestinationAlphaElement;
  /// Color operation.
  SelectElement _blendColorOperationElement;
  /// Alpha operation
  SelectElement _blendAlphaOperationElement;
  /// Whether the red channel is writable.
  InputElement _blendStateWriteRedElement;
  /// Whether the green channel is writable.
  InputElement _blendStateWriteGreenElement;
  /// Whether the blue channel is writable.
  InputElement _blendStateWriteBlueElement;
  /// Whether the alpha channel is writable.
  InputElement _blendStateWriteAlphaElement;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [RendererSelection] state.
   */
  RendererSelection()
  {
    _setupRasterizerState();
    _setupDepthState();
    _setupBlendState();
  }

  /**
   * Sets up the [RasterizerState] UI.
   */
  void _setupRasterizerState()
  {
    _rasterizerStateEnabledElement = query(_rasterizerStateEnabledId);
    _rasterizerStateEnabledElement.on.change.add((_) { _onRasterizerStateChanged(); });

    _rasterizerStateCullModeElement = query(_rasterizerStateCullModeId);
    _rasterizerStateCullModeElement.on.change.add((_) { _onRasterizerStateChanged(); });

    _rasterizerStateFrontFaceElement = query(_rasterizerStateFrontFaceId);
    _rasterizerStateFrontFaceElement.on.change.add((_) { _onRasterizerStateChanged(); });
  }

  /**
   * Sets up the [DepthState] UI.
   */
  void _setupDepthState()
  {
    _depthStateEnabledElement = query(_depthStateEnabledId);
    _depthStateEnabledElement.on.change.add((_) { _onDepthStateChanged(); });

    _depthStateWriteEnabledElement = query(_depthStateWriteEnabledId);
    _depthStateWriteEnabledElement.on.change.add((_) { _onDepthStateChanged(); });

    _depthStateComparisonElement = query(_depthStateComparisonId);
    _depthStateComparisonElement.on.change.add((_) { _onDepthStateChanged(); });
  }

  /**
   * Sets up the [BlendState] UI.
   */
  void _setupBlendState()
  {
    _blendStateEnabledElement = query(_blendStateEnabledId);
    _blendStateEnabledElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateSourceColorElement = query(_blendStateSourceColorId);
    _blendStateSourceColorElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateDestinationColorElement = query(_blendStateDestinationColorId);
    _blendStateDestinationColorElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendSourceAlphaElement = query(_blendStateSourceAlphaId);
    _blendSourceAlphaElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendDestinationAlphaElement = query(_blendStateDestinationAlphaId);
    _blendDestinationAlphaElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendColorOperationElement = query(_blendStateColorOperationId);
    _blendColorOperationElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendAlphaOperationElement = query(_blendStateAlphaOperationId);
    _blendAlphaOperationElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateWriteRedElement = query(_blendStateWriteRedId);
    _blendStateWriteRedElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateWriteGreenElement = query(_blendStateWriteGreenId);
    _blendStateWriteGreenElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateWriteBlueElement = query(_blendStateWriteBlueId);
    _blendStateWriteBlueElement.on.change.add((_) { _onBlendStateChanged(); });

    _blendStateWriteAlphaElement = query(_blendStateWriteAlphaId);
    _blendStateWriteAlphaElement.on.change.add((_) { _onBlendStateChanged(); });
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Saves the renderer information to a JSON.
   */
  Map toJson()
  {
    Map serialized = new Map();
    serialized[_blendStateName] = _blendStateToJson();
    serialized[_depthStateName] = _depthStateToJson();
    serialized[_rasterizerStateName] = _rasterizerStateToJson();

    return serialized;
  }

  /**
   * Loads the renderer information from a JSON.
   */
  void fromJson(Map json)
  {
    // Deserialize the blend state
    Map blendState = json[_blendStateName];
    assert(blendState != null);

    _blendStateFromJson(blendState);

    // Deserialize the depth state
    Map depthState = json[_depthStateName];
    assert(depthState != null);

    _depthStateFromJson(depthState);

    // Invoke all the callbacks
    Map rasterizerState = json[_rasterizerStateName];
    assert(rasterizerState != null);

    _rasterizerStateFromJson(rasterizerState);
  }

  /**
   * Saves the [BlendState] to a JSON.
   */
  Map _blendStateToJson()
  {
    Map blendState = new Map();

    blendState['blendEnable'] = _blendStateEnabledElement.checked;
    blendState['blendSourceColorFunc'] = _blendStateSourceColorElement.value;
    blendState['blendDestColorFunc'] = _blendStateDestinationColorElement.value;
    blendState['blendSourceAlphaFunc'] = _blendSourceAlphaElement.value;
    blendState['blendDestAlphaFunc'] = _blendDestinationAlphaElement.value;
    blendState['blendColorOp'] = _blendColorOperationElement.value;
    blendState['blendAlphaOp'] = _blendAlphaOperationElement.value;
    blendState['writeRenderTargetRed'] = _blendStateWriteRedElement.checked;
    blendState['writeRenderTargetGreen'] = _blendStateWriteGreenElement.checked;
    blendState['writeRenderTargetBlue'] = _blendStateWriteBlueElement.checked;
    blendState['writeRenderTargetAlpha'] = _blendStateWriteAlphaElement.checked;

    return blendState;
  }

  /**
   * Loads the [BlendState] from a JSON.
   */
  void _blendStateFromJson(Map blendState)
  {
    _blendStateEnabledElement.checked = blendState['blendEnable'];
    _blendStateSourceColorElement.value = blendState['blendSourceColorFunc'];
    _blendStateDestinationColorElement.value = blendState['blendDestColorFunc'];
    _blendSourceAlphaElement.value = blendState['blendSourceAlphaFunc'];
    _blendDestinationAlphaElement.value = blendState['blendDestAlphaFunc'];
    _blendColorOperationElement.value = blendState['blendColorOp'];
    _blendAlphaOperationElement.value = blendState['blendAlphaOp'];
    _blendStateWriteRedElement.checked = blendState['writeRenderTargetRed'];
    _blendStateWriteGreenElement.checked = blendState['writeRenderTargetGreen'];
    _blendStateWriteBlueElement.checked = blendState['writeRenderTargetBlue'];
    _blendStateWriteAlphaElement.checked = blendState['writeRenderTargetAlpha'];
  }

  /**
   * Saves the [DepthState] to a JSON.
   */
  Map _depthStateToJson()
  {
    Map depthState = new Map();

    depthState['depthTestEnabled'] = _depthStateEnabledElement.checked;
    depthState['depthWriteEnabled'] = _depthStateWriteEnabledElement.checked;
    depthState['depthComparisonOp'] = _depthStateComparisonElement.value;

    return depthState;
  }

  /**
   * Loads the [DepthState] from a JSON.
   */
  void _depthStateFromJson(Map depthState)
  {
    _depthStateEnabledElement.checked = depthState['depthTestEnabled'];
    _depthStateWriteEnabledElement.checked = depthState['depthWriteEnabled'];
    _depthStateComparisonElement.value = depthState['depthComparisonOp'];
  }

  /**
   * Saves the [RasterizerState] to a JSON.
   */
  Map _rasterizerStateToJson()
  {
    Map rasterizerState = new Map();

    rasterizerState['cullEnabled'] = _rasterizerStateEnabledElement.checked;
    rasterizerState['cullMode'] = _rasterizerStateCullModeElement.value;
    rasterizerState['cullFrontFace'] = _rasterizerStateFrontFaceElement.value;

    return rasterizerState;
  }

  /**
   * Loads the [RasterizerState] from a JSON.
   */
  void _rasterizerStateFromJson(Map rasterizerState)
  {
    _rasterizerStateEnabledElement.checked = rasterizerState['cullEnabled'];
    _rasterizerStateCullModeElement.value = rasterizerState['cullMode'];
    _rasterizerStateFrontFaceElement.value = rasterizerState['cullFrontFace'];
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback when the rasterizer state is changed.
   */
  void _onRasterizerStateChanged()
  {
    if (rasterizerStateCallback != null)
    {
      String props =
      '''
{
  "cullEnabled": ${_rasterizerStateEnabledElement.checked},
  "cullMode": "${_rasterizerStateCullModeElement.value}",
  "cullFrontFace": "${_rasterizerStateFrontFaceElement.value}"
}
      ''';

      rasterizerStateCallback(props);
    }
  }

  /**
   * Callback when the depth state is changed.
   */
  void _onDepthStateChanged()
  {
    if (depthStateCallback != null)
    {
      String props =
      '''
{
  "depthTestEnabled": ${_depthStateEnabledElement.checked},
  "depthWriteEnabled": ${_depthStateWriteEnabledElement.checked},
  "depthComparisonOp": "${_depthStateComparisonElement.value}"
}
      ''';

      depthStateCallback(props);
    }
  }

  /**
   * Callback when the blend state is changed.
   */
  void _onBlendStateChanged()
  {
    if (blendStateCallback != null)
    {
      String props =
      '''
{
  "blendEnable": ${_blendStateEnabledElement.checked},
  "blendSourceColorFunc": "${_blendStateSourceColorElement.value}",
  "blendDestColorFunc": "${_blendStateDestinationColorElement.value}",
  "blendSourceAlphaFunc": "${_blendSourceAlphaElement.value}",
  "blendDestAlphaFunc": "${_blendDestinationAlphaElement.value}",
  "blendColorOp": "${_blendColorOperationElement.value}",
  "blendAlphaOp": "${_blendAlphaOperationElement.value}",
  "writeRenderTargetRed": ${_blendStateWriteRedElement.checked},
  "writeRenderTargetGreen": ${_blendStateWriteGreenElement.checked},
  "writeRenderTargetBlue": ${_blendStateWriteBlueElement.checked},
  "writeRenderTargetAlpha": ${_blendStateWriteAlphaElement.checked}
}
      ''';

      blendStateCallback(props);
    }
  }
}
