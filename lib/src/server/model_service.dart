part of model_viewer_server;

class ModelService {
  Logger logger = new Logger("ModelService");
  ModelService() {
    objectory = new ObjectoryDirectConnectionImpl(ServerConfiguration.MongoUri, registerClasses, false);
  }
}