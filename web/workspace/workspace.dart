part of viewer;

/// Callback type for when the value is submitted
typedef void FileWrittenEvent(String value);

/**
 * Contains the current saved state of the application.
 */
class Workspace
{
  /// The directory holding the [Workspace]'s files.
  DirectoryEntry _directory;

  /**
   * Creates an instance of the [Workspace] class.
   */
  Workspace(DirectoryEntry entry)
  {
    _directory = entry;
  }

  /**
   * Saves a [Texture] to the file system.
   */
  Future<String> saveTexture(File file, int textureUnit)
  {
    String originalFilename = file.name;
    String extension = originalFilename.substring(originalFilename.lastIndexOf('.'));
    String filename = 'texture${textureUnit}$extension';
    Completer completer = new Completer();

    _writeFile(completer, filename, file);

    return completer.future;
  }

  /**
   * Write a file to the local filesystem.
   */
  void _writeFile(Completer completer, String fileName, Blob data)
  {
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
  }
}
