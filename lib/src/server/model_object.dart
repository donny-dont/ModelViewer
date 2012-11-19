part of model_viewer_server;

class ModelObject extends PersistentObject {
  String get modelState => getProperty('modelState');
  set modelState(String value) => setProperty('modelState', value);
}

void registerClasses() {
  objectory.registerClass('ModelObject', () => new ModelObject());
}

ObjectoryQueryBuilder get $ModelObject => new ObjectoryQueryBuilder('ModelObject');
