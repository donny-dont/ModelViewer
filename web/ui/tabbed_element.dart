part of viewer;

class TabbedElement
{
  static const String _selectedTabClass = 'selected';
  static const String _hiddenClass = 'hidden';

  List<Element> _tabs;
  List<Element> _tabContents;

  TabbedElement()
    : _tabs = new List<Element>()
    , _tabContents = new List<Element>();

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
