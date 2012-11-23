part of viewer;

/// Callback for when a uniform is changed.
typedef void UniformValueEvent(dynamic value);

/**
 * Base class for a UI element containing a uniform.
 */
abstract class UniformValue
{
  /// The name of the uniform.
  String _name;
  /// The type of the uniform.
  String _uniformType;
  /// Callback for when a uniform is changed.
  UniformValueEvent changeCallback;
  /// HTML element containing the uniform.
  DivElement _element;

  /**
   * Creates a new uniform value.
   */
  UniformValue(String name, String uniformType)
  {
    _name = name;
    _uniformType = uniformType;
  }

  /// Gets the name of the uniform.
  String get name => _name;

  /// Gets the type of uniform.
  String get uniformType => _uniformType;

  /// Gets the uniform's value.
  dynamic get value;

  /// HTML element containing the uniform value.
  DivElement get element => _element;

  /**
   * Creates the base uniform layout.
   */
  void _createLayout(TableCellElement cell)
  {
    // Create the root element
    _element = new DivElement();
    _element.classes.add('ui_row');

    // Create the header
    HeadingElement header = new HeadingElement.h2();
    header.innerHTML = _name;
    _element.nodes.add(header);

    // Add the table
    TableElement tableElement = new TableElement();
    _element.nodes.add(tableElement);

    TableRowElement row = new TableRowElement();
    tableElement.nodes.add(row);

    TableCellElement typeCell = new TableCellElement();
    typeCell.innerHTML = _uniformType;
    row.nodes.add(typeCell);
    row.nodes.add(cell);
  }
}

/**
 * UI element for a scalar uniform.
 */
class UniformScalarValue
{
  /// The uniform type name.
  static const String _uniformTypeName = '';

}

/**
 * UI element for a sampler.
 */
class UniformSamplerValue extends UniformValue
{
  /// The value contained in the uniform.
  int _uniformValue;
  /// The select element containing the value
  SelectElement _value;

  /**
   * Creates an instance of the [UniformSamplerValue] class.
   */
  UniformSamplerValue(String name)
    : super(name, UniformType.Sampler2dName)
  {
    _uniformValue = 0;
    _createElement();
  }

  /// Gets the uniform's value
  dynamic get value => _uniformValue;

  /**
   * Creates the HTML element holding the value.
   */
  void _createElement()
  {
    // Create the select element
    Map textureValues = {
      'Texture #0' : '0',
      'Texture #1' : '1',
      'Texture #2' : '2',
      'Texture #3' : '3',
      'Texture #4' : '4',
      'Texture #5' : '5',
      'Texture #6' : '6',
      'Texture #7' : '7',
      'Texture #8' : '8',
      'Texture #9' : '9',
      'Texture #10': '10',
      'Texture #11': '11',
      'Texture #12': '12',
      'Texture #13': '13',
      'Texture #14': '14',
      'Texture #15': '15',
    };

    TableCellElement cell = new TableCellElement();
    _value = new SelectElement();
    cell.nodes.add(_value);

    textureValues.forEach((key, value) {
      OptionElement option = new OptionElement();
      option.text = key;
      option.value = value;

      _value.nodes.add(option);
    });

    _value.on.change.add(_onValueChanged);

    // Add the UI
    _createLayout(cell);
  }

  void _onValueChanged(Event e)
  {
    _uniformValue = Math.parseInt(_value.value);

    if (changeCallback != null)
    {
      changeCallback(_uniformValue);
    }
  }
}

/**
 * UI element for a three dimentional scalar uniform.
 */
class UniformVector3Value extends UniformValue
{
  static const String _uniformTypeName = '';

  UniformVector3Value(String name)
    : super(name, _uniformTypeName)
  {

  }
}

/**
 * UI for interacting with uniforms.
 */
class UniformSelection
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Serialization name for the file.
  static const String _texturesName = 'textures';
  /// Built-in uniforms
  static final Map<String, String> _builtinUniformNames = {
    'uTime'                     : 'float',
    'uModelMatrix'              : 'mat4',
    'uModelViewMatrix'          : 'mat4',
    'uModelViewProjectionMatrix': 'mat4',
    'uProjectionMatrix'         : 'mat4',
    'uNormalMatrix'             : 'mat4'
  };

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [DivElement] containing the uniforms
  DivElement _parent;
  /// User defined uniforms
  Map<String, UniformValue> _uniforms;
  /// Callback for when a uniform is changed.
  UniformValueEvent changeCallback;

  /**
   * Initializes an instance of the [UniformSelection] class.
   */
  UniformSelection()
  {
    _parent = query('#uniform_area');
    assert(_parent != null);

    _uniforms = new Map<String, UniformValue>();
  }

  /**
   * Gets the values held in the uniforms.
   */
  Map<String, Map<String, dynamic>> get uniformValues
  {
    Map<String, Map<String, dynamic>> values = new Map<String, Map<String, dynamic>>();

    _uniforms.forEach((key, uniform) {
      Map<String, dynamic> value = new Map<String, dynamic>();

      value['type'] = uniform.uniformType;
      value['value'] = uniform.value;

      values[key] = value;
    });

    return values;
  }

  /**
   * Sets the uniform types to display in the UI.
   */
  set uniformTypes(Map<String, String> values)
  {
    Map<String, UniformValue> updateValues = new Map<String, UniformValue>();

    values.forEach((key, value) {
      // Ignore built-in uniforms
      if (!_builtinUniformNames.containsKey(key))
      {
        // See if the value is already present
        if (_uniforms.containsKey(key))
        {
          updateValues[key] = _uniforms[key];
        }
        else
        {
          updateValues[key] = _createUniformValue(key, value);
        }
      }
    });

    // Update the UI
    _updateUniformValues(updateValues);
  }

  /**
   * Updates the UI when the shader program has changed.
   */
  void _updateUniformValues(Map<String, UniformValue> values)
  {
    // Clear the current UI
    _uniforms.forEach((_, value) {
      value.changeCallback = null;
      value.element.remove();
    });

    // Add to the new UI
    _uniforms = values;

    int count = 1;

    // Add to the UI
    _uniforms.forEach((_, value) {
      DivElement element = value.element;

      // Style accordingly
      element.classes.remove('first');
      element.classes.remove('second');
      element.classes.add((count % 2 == 0) ? 'first' : 'second');

      // Attach the callback
      value.changeCallback = _onValueChanged;

      // Add to the parent
      _parent.nodes.add(element);

      count++;
    });
  }

  /**
   * Creates a [UniformValue].
   *
   * Determines the kind to create by looking at the [type].
   */
  static UniformValue _createUniformValue(String name, String type)
  {
    switch (type)
    {
      case UniformType.Sampler2dName: return new UniformSamplerValue(name);
    }

    assert(false);
    return new UniformSamplerValue(name);
  }

  /**
   * Callback for when a uniform value changes.
   */
  void _onValueChanged(_)
  {
    print('UniformSelection._onValueChanged');
    if (changeCallback != null)
    {
      changeCallback(uniformValues);
    }
  }
}
