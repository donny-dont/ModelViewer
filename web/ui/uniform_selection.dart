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

  /// Gets the type of uniform
  String get uniformType => _uniformType;

  /// Gets the uniform's value
  dynamic get value;

  /// HTML element containing the uniform value
  DivElement get element => _element;
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
  /// The uniform type name.
  static const String _uniformTypeName = '';

  UniformSamplerValue(String name)
    : super(name, _uniformTypeName)
  {
    _createElement();
  }

  void _createElement()
  {
    // Create the root element
    _element = new DivElement();
    _element.classes.add('ui_row');

    // Create the header
    HeadingElement header = new HeadingElement.h2();
    header.innerHTML = _name;
    _element.nodes.add(header);

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

    // Add the table
    TableElement tableElement = new TableElement();
    _element.nodes.add(tableElement);

    TableCellElement cell;

    TableRowElement row = new TableRowElement();
    tableElement.nodes.add(row);

    cell = new TableCellElement();
    cell.innerHTML = 'sampler2D';
    row.nodes.add(cell);

    cell = new TableCellElement();
    SelectElement select = new SelectElement();

    textureValues.forEach((key, value) {
      OptionElement option = new OptionElement();
      option.text = key;
      option.value = value;

      select.nodes.add(option);
    });

    cell.nodes.add(select);
    row.nodes.add(cell);
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

  /// The [DivElement] containing the uniforms
  DivElement _parent;

  /**
   * Initializes an instance of the [UniformSelection] class.
   */
  UniformSelection()
  {
    _parent = query('#uniform_area');
    assert(_parent != null);

    UniformSamplerValue uniform = new UniformSamplerValue('sampler');
    _parent.nodes.add(uniform.element);
  }
}
