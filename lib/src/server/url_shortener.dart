part of model_viewer_server;

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