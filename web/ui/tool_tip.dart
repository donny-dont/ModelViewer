part of viewer;

/**
 * Creates a tool tip for help.
 */
class ToolTip
{
  /// Element containing the tool tip.
  AnchorElement _element;

  /**
   * Creates an instance of the [ToolTip] class.
   */
  ToolTip(String tip)
  {
    _element = new AnchorElement();
    _element.$dom_setAttribute(_ElementNames.toolTipAttributeName, tip);

    ImageElement help = new ImageElement();
    _element.nodes.add(help);
    help.src = 'web/resources/images/help.png';

    help.on.mouseOver.add((_) {
      _element.classes.add(_ElementNames.toolTipClassName);
    });

    help.on.mouseOut.add((_) {
      _element.classes.remove(_ElementNames.toolTipClassName);
    });
  }

  /// Element containing the tool tip.
  AnchorElement get element => _element;
}
