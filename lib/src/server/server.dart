part of model_viewer_server;

class Server {
  Logger logger = new Logger("Server");
  final HttpServer server;
  StaticFileServer _staticFileServer;
  WebSocketServer _webSocketServer;
  
  void _onError(error) {
    logger.severe("HttpServer has died error: $error");
  }
  
  Server() : server = new HttpServer() {
    _staticFileServer = new StaticFileServer(server);
    _webSocketServer = new WebSocketServer(server);
    server.onError = _onError;
  }
  
  run() {
    logger.info("listing on http://${ServerConfiguration.IP}:${ServerConfiguration.PORT}");
    server.listen(ServerConfiguration.IP, ServerConfiguration.PORT);
  }
}