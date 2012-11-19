part of model_viewer_server;

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