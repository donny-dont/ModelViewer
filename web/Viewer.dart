library viewer;

import 'dart:html';
import 'dart:json';

import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';

//---------------------------------------------------------------------
// Source files
//---------------------------------------------------------------------

part 'client/json_object.dart';
part 'client/server_connection.dart';
part 'client/messages.dart';

part 'ui/element_names.dart';
part 'ui/model_selection.dart';
part 'ui/tabbed_element.dart';
part 'ui/texture_selection.dart';

ModelSelection _modelSelection;
TextureSelection _textureSelection;

void _setupUITab()
{
  TabbedElement element = new TabbedElement();
  element.addTab(_ElementNames.modelTabName, _ElementNames.modelAreaName);
  element.addTab(_ElementNames.textureTabName, _ElementNames.textureAreaName);
}

void main()
{
  _setupUITab();

  _modelSelection = new ModelSelection();
  _textureSelection = new TextureSelection();
}
