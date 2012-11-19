part of viewer;

/// Callback type for when the texture is changed.
typedef void TextureChangedEvent(File file, int textureUnit);

/**
 * UI for individual texture units.
 */
class TextureUnit
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Text to display when hovering over the drop area.
  static const String _dropText = 'Drag and Drop a Texture to Change';

  /// Serialization name for the file.
  static const String _textureFileName = 'filename';
  /// Serialization name for the wrapping mode in the u direction.
  static const String _wrapSName = 'wrapS';
  /// Serialization name for the wrapping mode in the v direction.
  static const String _wrapTName = 'wrapT';
  /// Serialization name for the minification filter.
  static const String _minificationFilterName = 'minFilter';
  /// Serialization name for the magnification filter.
  static const String _magnificationFilterName = 'maxFilter';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The location of the texture unit.
  int _location;
  /// Callback for when a texture change request occurs.
  TextureChangedEvent textureCallback;
  /// The element containing all the texture state information.
  DivElement _element;
  /// The element containing the texture.
  ImageElement _textureDisplay;
  /// The texture wrapping in the s direction.
  SelectElement _wrapS;
  /// The texture wrapping in the t direction.
  SelectElement _wrapT;
  /// The minification filter.
  SelectElement _minFilter;
  /// The magnification filer.
  SelectElement _magFilter;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Initializes an instance of the [TextureUnit] class.
   */
  TextureUnit(int location)
  {
    _location = location;

    // Create the root element
    _element = new DivElement();
    _element.classes.add('ui_row');
    _element.classes.add((location % 2 == 0) ? 'first' : 'second');

    // Create the header
    HeadingElement header = new HeadingElement.h2();
    header.innerHTML = 'Texture Unit #$location';
    _element.nodes.add(header);

    _createTextureDrop();
    _createSamplerState();
  }

  /**
   * Creates the texture drop area.
   */
  void _createTextureDrop()
  {
    DivElement textureArea = new DivElement();
    textureArea.classes.add('texture_element');

    _element.nodes.add(textureArea);

    // Add the texture drop area
    DivElement textureDropArea = new DivElement();
    textureDropArea.classes.add('texture_drop');
    textureDropArea.classes.add('drag_none');

    ParagraphElement dropText = new ParagraphElement();
    dropText.innerHTML = _dropText;
    dropText.classes.add('hidden');
    textureDropArea.nodes.add(dropText);

    _textureDisplay = new ImageElement();
    textureDropArea.nodes.add(_textureDisplay);

    textureArea.nodes.add(textureDropArea);

    textureArea.on.dragEnter.add((e) {
      textureDropArea.classes.remove('drag_none');
      textureDropArea.classes.add('drag_over');
    });
    textureArea.on.dragLeave.add((e) {
      textureDropArea.classes.remove('drag_over');
      textureDropArea.classes.add('drag_none');
    });
    textureArea.on.drop.add((e) {
      e.stopPropagation();
      e.preventDefault();

      textureDropArea.classes.remove('drag_over');
      textureDropArea.classes.add('drag_none');

      _onTextureChanged(e.dataTransfer.files);
    });

    textureArea.on.mouseOver.add((_) {
      dropText.classes.remove('hidden');
    });
    textureArea.on.mouseOut.add((_) {
      dropText.classes.add('hidden');
    });
  }

  /**
   * Creates the sampler state.
   */
  void _createSamplerState()
  {
    DivElement samplerArea = new DivElement();
    samplerArea.classes.add('sampler_state');

    _element.nodes.add(samplerArea);

    // Add the table
    TableElement tableElement = new TableElement();
    samplerArea.nodes.add(tableElement);

    Map wrapValues = {
      'Clamped': 'TextureWrapClampToEdge',
      'Mirror' : 'TextureWrapMirroredRepeat',
      'Repeat' : 'TextureWrapRepeat'
    };

    Map minFilterValues = {
      'Linear'                : 'TextureMinFilterLinear',
      'Nearest'               : 'TextureMinFilterNearest',
      'Nearest Mipmap Nearest': 'TextureMinFilterNearestMipmapNearest',
      'Nearest Mipmap Linear' : 'TextureMinFilterNearestMipmapLinear',
      'Linear Mipmap Nearest' : 'TextureMinFilterLinearMipmapNearest',
      'Linear Mipmap Linear'  : 'TextureMinFilterLinearMipmapLinear'
    };

    Map magFilterValues = {
      'Linear' : 'TextureMagFilterLinear',
      'Nearest': 'TextureMagFilterNearest'
    };

    // Add the wrapping along S
    _wrapS = _createSelectElement(tableElement, 'Wrap S', wrapValues);
    _wrapS.on.change.add(_onSamplerStateChanged);

    // Add the wrapping along T
    _wrapT = _createSelectElement(tableElement, 'Wrap T', wrapValues);
    _wrapT.on.change.add(_onSamplerStateChanged);

    // Add the minification filter
    _minFilter = _createSelectElement(tableElement, 'Minification Filter', minFilterValues);
    _minFilter.on.change.add(_onSamplerStateChanged);

    // Add the magnification filter
    _magFilter = _createSelectElement(tableElement, 'Magnification Filter', magFilterValues);
    _magFilter.on.change.add(_onSamplerStateChanged);
  }

  /**
   * Creates a [SelectElement] to modify [SamplerState].
   */
  static SelectElement _createSelectElement(TableElement tableElement, String name, Map<String, String> values)
  {
    TableCellElement cell;

    TableRowElement row = new TableRowElement();
    tableElement.nodes.add(row);

    cell = new TableCellElement();
    cell.innerHTML = name;
    row.nodes.add(cell);

    cell = new TableCellElement();
    SelectElement select = new SelectElement();

    values.forEach((key, value) {
      OptionElement option = new OptionElement();
      option.text = key;
      option.value = value;

      select.nodes.add(option);
    });

    cell.nodes.add(select);
    row.nodes.add(cell);

    return select;
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The element containing all the texture state information
  DivElement get element => _element;

  /// The texture image contained in the [TextureUnit].
  String get texture => _textureDisplay.src;
  set texture(String value) { _textureDisplay.src = value; }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Saves the renderer information to a JSON.
   */
  Map toJson()
  {
    Map serialized = new Map();

    serialized[_textureFileName] = _textureDisplay.src;
    serialized[_wrapSName] = _wrapS.value;
    serialized[_wrapTName] = _wrapT.value;
    serialized[_minificationFilterName] = _minFilter.value;
    serialized[_magnificationFilterName] = _magFilter.value;

    return serialized;
  }

  /**
   * Loads the renderer information from a JSON.
   */
  void fromJson(Map json)
  {
    _textureDisplay.src = json[_textureFileName];
    _wrapS.value = json[_wrapSName];
    _wrapT.value = json[_wrapTName];
    _minFilter.value = json[_minificationFilterName];
    _magFilter.value = json[_magnificationFilterName];
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when the [Texture] is changed.
   */
  void _onTextureChanged(List<File> files)
  {
    if ((textureCallback != null) && (files.length > 0))
    {
      textureCallback(files[0], _location);
    }
  }

  /**
   * Callback for when the [SampleState] is changed.
   */
  void _onSamplerStateChanged(_)
  {

  }
}

/**
 * UI for interacting with [Texture]s.
 */
class TextureSelection
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Serialization name for the file.
  static const String _texturesName = 'textures';
  /**
   * The maximum number of textures WebGL supports
   *
   * This might not be the number the current graphics card supports.
   */
  static const int _maxTextureUnits = 16;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [DivElement] containing the Texture
  DivElement _parent;
  /// Callback for when a texture change request occurs.
  TextureChangedEvent textureCallback;
  /// The individual [TextureUnit]s.
  List<TextureUnit> _textureUnits;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Initializes an instance of the [TextureSelection] class.
   */
  TextureSelection()
  {
    _parent = query('#texture_area');
    assert(_parent != null);

    _textureUnits = new List<TextureUnit>();

    for (int i = 0; i < _maxTextureUnits; ++i)
    {
      TextureUnit textureUnit = new TextureUnit(i);
      textureUnit.textureCallback = _onTextureChanged;

      _textureUnits.add(textureUnit);
      _parent.nodes.add(textureUnit.element);
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The individual [TextureUnit]s.
  List<TextureUnit> get textureUnits => _textureUnits;

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Saves the renderer information to a JSON.
   */
  Map toJson()
  {
    Map serialized = new Map();
    List<Map> serializedTextureUnits = new List<Map>();

    for (int i = 0; i < _maxTextureUnits; ++i)
    {
      serializedTextureUnits.add(_textureUnits[i].toJson());
    }

    serialized[_texturesName] = serializedTextureUnits;

    return serialized;
  }

  /**
   * Loads the renderer information from a JSON.
   */
  void fromJson(Map json)
  {
    List<Map> serializedTextureUnits = json[_texturesName];

    for (int i = 0; i < _maxTextureUnits; ++i)
    {
      _textureUnits[i].fromJson(serializedTextureUnits[i]);
    }
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  /**
   * Callback for when a [Texture] is changed.
   */
  void _onTextureChanged(File file, int textureUnit)
  {
    // Propagate the event
    if (textureCallback != null)
    {
      textureCallback(file, textureUnit);
    }
  }
}
