part of viewer;

/**
 * UI for interacting with [Texture]s.
 */
class TextureSelection
{
  static const String _dropText = 'Drag and Drop a Texture to Change';

  /// The [DivElement] containing the Texture
  DivElement _parent;

  /**
   * Initializes an instance of the [TextureSelection] class.
   *
   *
   */
  TextureSelection(/*GraphicsDeviceCapabilities capabilities*/)
  {
    _parent = query('#texture_area');
    assert(_parent != null);

    int textureUnits = 8;//capabilities.textureUnits;
    bool anisotropic = true;//capabilities.hasAnisotropicFiltering;

    for (int i = 0; i < textureUnits; ++i)
    {
      _addTextureArea(i, anisotropic);
    }
  }

  /**
   * Adds an additional texture area.
   */
  void _addTextureArea(int index, bool anisotropic)
  {
    // Setup the UI area
    DivElement elementArea = new DivElement();
    elementArea.classes.add('texture_unit');
    elementArea.classes.add((index % 2 == 0) ? 'first' : 'second');

    _parent.nodes.add(elementArea);

    // Create the header
    HeadingElement header = new HeadingElement.h2();
    header.innerHTML = 'Texture Unit #$index';

    elementArea.nodes.add(header);

    // Create the texture

    // Add the texture area
    {
      DivElement textureArea = new DivElement();
      textureArea.classes.add('texture_element');

      elementArea.nodes.add(textureArea);

      // Add the texture drop area
      DivElement textureDropArea = new DivElement();
      textureDropArea.classes.add('texture_drop');
      textureDropArea.classes.add('drag_none');

      ParagraphElement dropText = new ParagraphElement();
      dropText.innerHTML = _dropText;
      dropText.classes.add('hidden');
      textureDropArea.nodes.add(dropText);

      ImageElement textureDisplay = new ImageElement();
      textureDropArea.nodes.add(textureDisplay);

      textureArea.nodes.add(textureDropArea);

      textureArea.on.dragEnter.add((_) {
        textureDropArea.classes.remove('drag_none');
        textureDropArea.classes.add('drag_over');
      });
      textureArea.on.dragLeave.add((_) {
        textureDropArea.classes.remove('drag_over');
        textureDropArea.classes.add('drag_none');
      });

      textureArea.on.mouseOver.add((_) {
        dropText.classes.remove('hidden');
      });
      textureArea.on.mouseOut.add((_) {
        dropText.classes.add('hidden');
      });
    }

    // Add the sampler area
    {
      DivElement samplerArea = new DivElement();
      samplerArea.classes.add('sampler_state');

      elementArea.nodes.add(samplerArea);

      // Add the table
      TableElement tableElement = new TableElement();
      samplerArea.nodes.add(tableElement);

      Map wrapValues = {
       'Clamped': 'TextureWrapClampToEdge',
       'Mirror' : 'TextureWrapMirroredRepeat',
       'Repeat' : 'TextureWrapRepeat'
      };

      Map filterValues = {

      };

      // Add the wrapping along S
      SelectElement wrapS = _createSelectElement(tableElement, 'Wrap S', wrapValues);

      // Add the wrapping along T
      SelectElement wrapT = _createSelectElement(tableElement, 'Wrap T', wrapValues);

      // Add the minification filter
      SelectElement minFilter = _createSelectElement(tableElement, 'Minification Filter', filterValues);

      // Add the magnification filter
      SelectElement maxFilter = _createSelectElement(tableElement, 'Magnification Filter', filterValues);
    }
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
  }
}
