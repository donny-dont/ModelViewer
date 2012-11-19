part of model_viewer_server;

class ServerConfiguration {
  // TODO: read settings from filesystem json document. 
  static final MongoUri = 'mongodb://127.0.0.1/objectory_shader_app';
  static final IP = '0.0.0.0';
  static final PORT = 8080;
  static final MODELWS = '/ws';
}