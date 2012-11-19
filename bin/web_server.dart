library web_server;

import "dart:io";
import 'dart:json';
import 'dart:uri';
import "dart:utf";
import "dart:math";
import "package:logging/logging.dart";

//import 'package:objectory/objectory.dart';
import 'package:objectory/objectory_console.dart';


void main() {
  new Server().run();
}

class ServerConfiguration {
  // TODO: read settings from filesystem json document. 
  static final MongoUri = 'mongodb://127.0.0.1/objectory_shader_app';
  static final IP = '0.0.0.0';
  static final PORT = 8080;
  static final MODELWS = '/ws';
}

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

class StaticFileServer {
  Logger logger = new Logger("StaticFileServer");
  Map staticFiles = new Map();
  String webFolder = "web";
  
  HttpServer _server;
  Directory _directory;
  DirectoryLister _directoryLister;
  
  void _onError(error) {
    logger.severe("Not able to list directory $webFolder, $error");
    //exit(0);
  }
  
  void _onFile(String file) {
    // Ignore paths that get introduced by pub's packages folder
    if (file.contains('.pub-cache') || file.contains('dart-sdk')) {
      return;
    }
    
    Path path = new Path(file); 
    String cwd = new Directory.current().path;
    String nfile = file.replaceFirst(cwd, '');
    staticFiles[nfile] = file;
  }
  
  void _onDone(completed) {
    if (completed == true) {
      // Load up request handlers for all static content.
      _loadStaticFiles();
      
      // If we dont find our static content, then try the absolute path for the file.
      // This is a workaround cause pub does not support deployment yet. 
      _server.defaultRequestHandler = _defaultStaticFileRequestHandler;
    }
  }
  
  void _loadStaticFiles() {
    staticFiles.forEach((key, value) {
      _server.addRequestHandler((req) => req.path == key, (HttpRequest req, HttpResponse res) {
        File file = new File(value);
        file.openInputStream().pipe(res.outputStream);
      });
    });
  }
  
  void _defaultStaticFileRequestHandler(HttpRequest req, HttpResponse res) {
    logger.info("request ${req.path}");
    // TODO(adam): handle requests for files in pub-cache or dart-sdk better
    File file = new File(req.path.substring(1));
    if (file.existsSync()) {
      file.openInputStream().pipe(res.outputStream);
    } else {
      res.outputStream.close();
    }
  }
  
  StaticFileServer(this._server) {
    _directory = new Directory.fromPath(new Path(webFolder));
    _directoryLister = _directory.list();
    _directoryLister.onError = _onError;
    _directoryLister.onFile = _onFile;
    _directoryLister.onDone = _onDone;
  }
}


class WebSocketCommands {
  static final COMMAND = "command";
  static final STORE = "store";
  static final LOAD = "load";
}

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

class ModelService {
  Logger logger = new Logger("ModelService");
  ModelService() {
    objectory = new ObjectoryDirectConnectionImpl(ServerConfiguration.MongoUri, registerClasses, false);
  }
}

class ModelObject extends PersistentObject {
  String get modelState => getProperty('modelState');
  set modelState(String value) => setProperty('modelState', value);
}

void registerClasses() {
  objectory.registerClass('ModelObject', () => new ModelObject());
}

ObjectoryQueryBuilder get $ModelObject => new ObjectoryQueryBuilder('ModelObject');

class UrlShortener {
  Logger logger = new Logger("UrlShortener");
  
  static const String SHORTEN = "shorten";
  static const String EXPAND = "expand";
  static const String ANALYTICS = "analytics";
  final String googUrl = 'https://www.googleapis.com/urlshortener/v1/url';
  
  final String url;
  final String command;
  final String key;
  final String curlPath;
  
  UrlShortener({this.url: "http://www.google.com", this.command: "shorten", this.key: '', this.curlPath: "curl"});
  
  Future execute() {
    switch(command) {
      case SHORTEN:
        return shorten();
      case EXPAND:
        return expand();
      case ANALYTICS:
        return analytics();
    }
    
    logger.warning("$command is not a valid command");
    var c = new Completer();
    c.complete('{ "error" : "execute failed"');
    return c.future;
  }
  
  Future executeCurl(List<String> processArgs) {
    Completer c = new Completer();
    ProcessOptions processOptions = new ProcessOptions();
    Directory directory = new Directory.current();
    processOptions.workingDirectory = directory.path;
    processOptions.environment = new Map();
    logger.finest("$curlPath $processArgs");
    Process.run(curlPath, processArgs, processOptions)
    ..handleException((error) {
      logger.severe("Error: $error");
      c.completeException(error);
    })
    ..then((ProcessResult processResult) {
      c.complete(processResult.stdout);
    });
    
    return c.future;
  }
  
  Future shorten() {
    var keyParam = key.isEmpty ? "" : "?&key=$key";
    var args = ["$googUrl$keyParam", "-H", 'Content-Type: application/json',
                 "-d", JSON.stringify({"longUrl": url})];
    return executeCurl(args);
  }
  
  Future expand() {
    var keyParam = key.isEmpty ? "" : "&key=$key";
    var args = ["$googUrl?shortUrl=$url$keyParam"];
    return executeCurl(args);
  }
  
  Future analytics() {
    var keyParam = key.isEmpty ? "" : "&key=$key";
    var args = ["$googUrl?shortUrl=$url&projection=FULL$keyParam"];
    return executeCurl(args);
  }
}