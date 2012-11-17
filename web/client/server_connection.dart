part of viewer;

/**
 * A connection to the server that processes model data.
 *
 * The connection is made over WebSockets. If the connection
 * is lost it will attemp to reconnect it.
 */
class ServerConnection
{
  /// The URL for the [WebSocket] server.
  String _url;
  /// The [WebSocket] connection.
  WebSocket _connection;

  /**
   * Creates an instance of the [ServerConnection] class.
   *
   * When requested a connection will be made using the supplied
   * [url].
   */
  ServerConnection(String url)
    : _url = url;

  /**
   * Attempts to connect to the specified [WebSocket] server.
   */
  void connect()
  {
    if (_shouldReconnect)
    {
      _reconnect();
    }
  }

  void send(MessageBase message)
  {
    if (isConnected)
    {
      _connection.send(message.type);
      _connection.send(message.message);
    }
  }

  /**
   * Whether there is a valid connection to the server.
   */
  bool get isConnected
  {
    return (_connection != null) && (_connection.readyState == WebSocket.OPEN);
  }

  /**
   * Whether a reconnect attempt should be made.
   */
  bool get _shouldReconnect
  {
    if (_connection == null)
    {
      return true;
    }

    return (_connection.readyState == WebSocket.CLOSED);
  }

  /**
   * Reconnects to the server.
   *
   * Called on initial connection.
   */
  void _reconnect()
  {
    _connection = new WebSocket(_url);

    _connection.on.open.add(_onConnected);
    _connection.on.close.add(_onClosed);
    _connection.on.error.add(_onError);
    _connection.on.message.add(_onMessage);
  }

  /**
   * Handles a connection event.
   */
  void _onConnected(_)
  {

  }

  /**
   * Handles a close event.
   */
  void _onClosed(CloseEvent e)
  {

  }

  /**
   * Handles an error event.
   */
  void _onError(ErrorEvent e)
  {

  }

  /**
   * Handles a message event.
   */
  void _onMessage(MessageEvent e)
  {

  }
}
