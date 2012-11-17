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

part 'ui/texture_selection.dart';

TextureSelection _textureSelection;

void main()
{
  _textureSelection = new TextureSelection();
}
