part of viewer;

/**
 * A container for a tabbed display.
 */
class TabbedElement
{
  static const String _selectedTabClass = 'selected';
  static const String _hiddenClass = 'hidden';

  /// The tabs associated with the container.
  List<Element> _tabs;
  /// The contents associated with the container.
  List<Element> _tabContents;

  /**
   * Creates an instance of the [TabbedElement] class.
   */
  TabbedElement()
    : _tabs = new List<Element>()
    , _tabContents = new List<Element>();

  /**
   * Adds a tab to the container.
   *
   * The [tabId] specifies the identifier of the tab,
   * while the [tabContent] specifies the area to display.
   */
  void addTab(String tabId, String tabContentId)
  {
    int index = _tabs.length;

    Element tab = document.query(tabId);
    assert(tab != null);

    _tabs.add(tab);

    Element tabContent = document.query(tabContentId);
    assert(tabContent != null);

    _tabContents.add(tabContent);

    tab.on.click.add((_) {
      _onSelected(index);
    });
  }

  /**
   * Callback for when a tab is clicked.
   *
   * Displays the tab at the given [index].
   */
  void _onSelected(int index)
  {
    int length = _tabs.length;
    for (int i = 0; i < length; ++i)
    {
      if (i == index)
      {
        _tabs[i].classes.add(_selectedTabClass);
        _tabContents[i].classes.remove(_hiddenClass);
      }
      else
      {
        _tabs[i].classes.remove(_selectedTabClass);
        _tabContents[i].classes.add(_hiddenClass);
      }
    }
  }
}
