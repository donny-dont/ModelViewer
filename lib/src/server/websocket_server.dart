part of model_viewer_server;

class WebSocketServer {
  Logger logger = new Logger("WebSocketServer");
  WebSocketHandler wsHandler;
  HttpServer _server;
  ModelService _modelService;
  
  _createModelService() {
    _modelService = new ModelService();
    objectory.initDomainModel().then((_) {
      wsHandler.onOpen = _onOpen;
    });
  }
  
  void _onOpen(WebSocketConnection conn) {
    conn.onMessage = _onMessage;
    conn.onClosed = _onClosed;
  }
  
  void _onMessage(message) {
    
  }
  
  void _onClosed(int status, String reason) {
    logger.info("conn.onClosed status=${status}, reason=${reason}");
  }
  
  WebSocketServer(this._server) {
    wsHandler = new WebSocketHandler();
    _server.addRequestHandler((req) => req.path == ServerConfiguration.MODELWS, wsHandler.onRequest);
    _createModelService();
  }
}