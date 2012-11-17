part of viewer;

/**
 * Grouping of message types.
 *
 * Should be an enum but that's not in the language yet..
 */
class Messages
{
  static const int sendModel = 0;
  static const int receiveModel = 1;
}

/**
 * Base class for messages sent between the server and client.
 */
abstract class MessageBase
{
  /// The type of message being sent.
  int _type;

  MessageBase(int this._type);

  /**
   * The type of message being sent.
   */
  int get type;

  /**
   * Whether the message payload is JSON data.
   */
  bool get isJson;

  /**
   * Whether the message payload is binary data.
   */
  bool get isBinary;

  /**
   * The contents of the [message].
   */
  dynamic get message;
}

/**
 * Message containing a JSON payload.
 */
class JsonMessage extends MessageBase
{
  /**
   * Creates a [JsonMessage] from the supplied [json] map.
   */
  JsonMessage(int type, Map json)
    : super(type)
  {

  }

  /**
   * Creates a [JsonMessage] from the values within [jsonText].
   */
  JsonMessage.fromJson(int type, String jsonText)
    : super(type)
  {

  }

  /**
   * Whether the message payload is JSON data.
   */
  bool get isJson => true;

  /**
   * Whether the message payload is binary data.
   */
  bool get isBinary => false;

  /**
   * The contents of the [message].
   */
  dynamic get message => null;
}
