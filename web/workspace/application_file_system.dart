part of viewer;

/**
 * Wrapper around the filesystem for the application.
 */
class ApplicationFileSystem
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /**
   * The number of MB's to request from the client.
   *
   * Currently 20 MBs
   */
  static const int _bytesToRequest = 20 * 1024 * 1024;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [DOMFileSystem] for the application.
  DOMFileSystem _fileSystem;
  /// The number of bytes alotted.
  int _bytesGranted;
  /// The available [Workspace]s.
  List<Workspace> _workspaces;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates a new instance of the [ApplicationFilesystem].
   */
  ApplicationFileSystem()
  {
    _workspaces = new List<Workspace>();

    // Request a quota
    window.webkitStorageInfo.requestQuota(LocalWindow.PERSISTENT, _bytesToRequest, (grantedBytes) {
      _bytesGranted = grantedBytes;

      // Request the file system
      window.webkitRequestFileSystem(LocalWindow.PERSISTENT, grantedBytes, _onFileSystemCreated, _onFileSystemError);
    }, _onQuotaError);
  }

  /**
   * Callback for when a quota error occurs.
   */
  void _onQuotaError(DOMException error) { }

  /**
   * Callback for when the file system is created.
   */
  void _onFileSystemCreated(DOMFileSystem fileSystem)
  {
    _fileSystem = fileSystem;

    DirectoryReader directoryReader = _fileSystem.root.createReader();
    _workspaces.clear();

    _searchForWorkspaces(directoryReader);
  }

  /**
   * Callback for when an error occurs with the file system API.
   */
  static void _onFileSystemError(FileError error)
  {
    String messageCode = '';

    switch (error.code) {
      case FileError.QUOTA_EXCEEDED_ERR: messageCode = 'Quota Exceeded'; break;
      case FileError.NOT_FOUND_ERR: messageCode = 'Not found '; break;
      case FileError.SECURITY_ERR: messageCode = 'Security Error'; break;
      case FileError.INVALID_MODIFICATION_ERR: messageCode = 'Invalid Modificaiton'; break;
      case FileError.INVALID_STATE_ERR: messageCode = 'Invalid State'; break;
      default: messageCode = 'Unknown error'; break;
    }

    print('Filesystem error: $messageCode');
  }

  //---------------------------------------------------------------------
  // Workspace
  //---------------------------------------------------------------------

  /**
   * Creates a new [Workspace].
   */
  Future<Workspace> createWorkspace()
  {
    Completer workspaceCreation = new Completer();
    Date currentTime = new Date.now();
    String newDirectoryName = '${currentTime.millisecondsSinceEpoch}';

    _fileSystem.root.getDirectory(newDirectoryName, options: {'create': true}, successCallback: (directoryEntry) {
      Workspace workspace = new Workspace(directoryEntry);

      workspaceCreation.complete(workspace);
    }, errorCallback: _onFileSystemError);

    return workspaceCreation.future;
  }

  /**
   * Loads a [Workspace] already present on the file system.
   */
  Future<Workspace> loadWorkspace(String name)
  {

  }

  /**
   * Populates a list of [Workspace]s.
   */
  void _searchForWorkspaces(DirectoryReader directoryReader)
  {
    directoryReader.readEntries((List<Entry> results) {
      if (results.length != 0)
      {
        for (Entry entry in results)
        {
          if (entry.isDirectory)
          {
            print(entry.name);
            _workspaces.add(new Workspace(entry));
          }
        }

        // It isn't guaranteed that all results will be
        // returned so call the function until the length
        // of the result is zero
        _searchForWorkspaces(directoryReader);
      }
    });
  }
}
