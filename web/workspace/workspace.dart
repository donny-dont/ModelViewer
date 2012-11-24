part of viewer;

/// Callback type for when the value is submitted
typedef void FileWrittenEvent(String value);

/**
 * Contains the current saved state of the application.
 */
class Workspace
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The filename for the workspace metadata.
  static const _metadataFileName = 'meta.json';
  /// The filename for the state.
  static const _stateFileName = 'state.json';
  /// The filename for the model.
  static const _modelFileName = 'model.mesh';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The directory holding the [Workspace]'s files.
  DirectoryEntry _directory;
  /// The name of the workspace.
  String _name;
  /// The path to the workspace.
  String _path;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [Workspace] class.
   */
  Workspace(DirectoryEntry entry, [String name = ''])
  {
    _directory = entry;
    _path = _directory.fullPath;
    _name = name;

    print('Path: $_path');

    if (_name.isEmpty)
    {
      _readJson(_metadataFileName).then((result) {
        _name = result['name'];
      });
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The name of the workspace
  String get name => _name;
  /// The path to the workspace
  String get path => _path;

  //---------------------------------------------------------------------
  // File reading
  //---------------------------------------------------------------------

  /**
   * Reads a json from the local filesystem.
   */
  Future<Map> _readJson(String fileName)
  {
    Completer completer = new Completer();

    _directory.getFile(fileName, options: {}, successCallback: (fileEntry) {
      fileEntry.file((file) {
        FileReader fileReader = new FileReader();

        fileReader.on.loadEnd.add((_) {
          Map values = JSON.parse(fileReader.result);

          _name = values['name'];
          print('Workspace name: $_name');
        });

        fileReader.readAsText(file);
      });
    }, errorCallback: ApplicationFileSystem._onFileSystemError);

    return completer.future;
  }

  //---------------------------------------------------------------------
  // File writing
  //---------------------------------------------------------------------

  /**
   * Saves metadata to the file system.
   */
  Future<String> saveMetadata(String values)
  {
    return _writeJson(_metadataFileName, values);
  }

  /**
   * Saves a model to the file system.
   */
  Future<String> saveModel(File file)
  {
    return _writeFile(_modelFileName, file);
  }

  /**
   * Saves a [Texture] to the file system.
   */
  Future<String> saveTexture(File file, int textureUnit)
  {
    String originalFilename = file.name;
    String extension = originalFilename.substring(originalFilename.lastIndexOf('.'));
    String fileName = 'texture${textureUnit}$extension';

    return _writeFile(fileName, file);
  }

  /**
   * Writes a json to the local filesystem.
   */
  Future<String> _writeJson(String fileName, String json)
  {
    Blob data = new Blob([json], 'text/plain');

    return _writeFile(fileName, data);
  }

  /**
   * Write a file to the local filesystem.
   */
  Future<String> _writeFile(String fileName, Blob data)
  {
    Completer completer = new Completer();

    Map options = { 'create': true };

    _directory.getFile(fileName, options: { 'create': true }, successCallback: (fileEntry) {
      fileEntry.createWriter((fileWriter) {
        fileWriter.on.writeEnd.add((_) {
          String url = fileEntry.toURL();

          completer.complete(url);
        });

        fileWriter.write(data);
      });
    }, errorCallback: ApplicationFileSystem._onFileSystemError);

    return completer.future;
  }

  //---------------------------------------------------------------------
  // Deletion
  //---------------------------------------------------------------------

  /**
   * Deletes the contents of the workspace.
   */
  void clear()
  {
    DirectoryReader directoryReader = _directory.createReader();

    _clearWorkspace(directoryReader);
  }

  /**
   * Deletes each individual file in the workspace.
   */
  void _clearWorkspace(DirectoryReader directoryReader)
  {
    directoryReader.readEntries((List<Entry> results) {
      if (results.length != 0)
      {
        for (Entry entry in results)
        {
          entry.remove(() {
            print('Removed ${entry.name}');
          }, ApplicationFileSystem._onFileSystemError);
        }

        // It isn't guaranteed that all results will be
        // returned so call the function until the length
        // of the result is zero
        _clearWorkspace(directoryReader);
      }
    });
  }
}
