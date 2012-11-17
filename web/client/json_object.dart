part of viewer;

/**
 * Treats a [Map] as an object.
 *
 * Abuses noSuchMethod to allow field access to [Map] data.
 */
class JsonObject
{
  /// [Map] containing JSON data.
  Map _values;

  /**
   * Creates an instance of [JsonObject] from [Map] data.
   */
  JsonObject(Map json)
    : _values = json;

  /**
   * Initializes an instance of [JsonObject] from a string holding JSON data.
   */
  JsonObject.fromJson(String json)
  {
    _values = JSON.parse(json);
  }

  /**
   * Override to allow for access to map data.
   */
  dynamic noSuchMethod(InvocationMirror invocation)
  {
    String memberName = invocation.memberName;

    if (memberName.startsWith('get:'))
    {
      String getterName = memberName.split(':')[1];

      if (_values.containsKey(getterName))
      {
        dynamic value = _values[getterName];

        return (value is Map) ? new JsonObject(value) : value;
      }
    }

    // Method not found
    super.noSuchMethod(invocation);
  }
}
