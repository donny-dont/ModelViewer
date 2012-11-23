part of viewer;

/**
 * Container for the element id's and classes.
 *
 * Used to centralize all the names.
 */
class _ElementNames
{
  //---------------------------------------------------------------------
  // Menu bar
  //---------------------------------------------------------------------

  /// The ID of the new button.
  static const String newFileButtonName = '#new_file_button';
  /// The ID of the save button.
  static const String saveFileButtonName = '#save_file_button';
  /// The ID of the fullscreen button.
  static const String fullscreenButtonName = '#fullscreen_button';
  /// The ID of the about dialog.
  static const String aboutButtonName = '#about_button';

  //---------------------------------------------------------------------
  // UI area tabs
  //---------------------------------------------------------------------

  /// The ID of the tab for the model area.
  static const String modelTabName = '#model_tab';
  /// The ID of the body for the model area.
  static const String modelAreaName = '#model_area';

  /// The ID of the tab for the textures area.
  static const String textureTabName = '#texture_tab';
  /// The ID of the body for the textures area.
  static const String textureAreaName = '#texture_area';

  /// The ID of the tab for the vertex shader area.
  static const String vertexShaderTabName = '#vertex_shader_tab';
  /// The ID of the body for the vertex shader area.
  static const String vertexShaderAreaName = '#vertex_shader_area';

  /// The ID of the tab for the fragment shader area.
  static const String fragmentShaderTabName = '#fragment_shader_tab';
  /// The ID of the body for the fragment shader area.
  static const String fragmentShaderAreaName = '#fragment_shader_area';

  /// The ID of the tab for the uniforms area.
  static const String uniformTabName = '#uniform_tab';
  /// The ID of the body for the uniforms area.
  static const String uniformAreaName = '#uniform_area';

  /// The ID of the tab for the textures area.
  static const String rendererTabName = '#renderer_tab';
  /// The ID of the body for the textures area.
  static const String rendererAreaName = '#renderer_area';

  //---------------------------------------------------------------------
  // UI dialogs
  //---------------------------------------------------------------------

  /// The ID of the modal dialog for the filesystem.
  static const String filesystemDialogName = '#filesystem_access_dialog';
  /// The ID of the modal dialog for the about box.
  static const String aboutDialogName = '#about_dialog';
  /// The ID of the modal dialog for file saving.
  static const String saveDialogName = '#save_as_dialog';
  /// The ID of the modal dialog for file loading.
  static const String loadDialogName = '#load_dialog';

  /// The class name of a submit button.
  static const String submitButtonClassName = '.submit_button';
  /// The class name of a cancel button.
  static const String cancelButtonClassName = '.cancel_button';
}
