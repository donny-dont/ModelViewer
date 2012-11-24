part of viewer;

/// Callback type for when the filesystem is ready.
typedef void FileSystemReadyEvent();

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
  /// The name of the temporary workspace.
  static const String _tempWorkspaceName = 'temp';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [DOMFileSystem] for the application.
  DOMFileSystem _fileSystem;
  /// The number of bytes alotted.
  int _bytesGranted;
  /// The temporary [Workspace].
  Workspace _tempWorkspace;
  /// The available [Workspace]s.
  List<Workspace> _workspaces;
  /// Callback for when the filesystem is ready.
  FileSystemReadyEvent _fileSystemReadyCallback;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates a new instance of the [ApplicationFilesystem].
   */
  ApplicationFileSystem(FileSystemReadyEvent fileSystemReadycallback)
  {
    _fileSystemReadyCallback = fileSystemReadycallback;

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

    if (_tempWorkspace == null)
    {
      _createWorkspace(_tempWorkspaceName).then((workspace) {
        _tempWorkspace = workspace;

        _onFileSystemReady();
      });
    }
    else
    {
      _onFileSystemReady();
    }
  }

  /**
   * Callback for when the file system is ready.
   */
  void _onFileSystemReady()
  {
    if (_fileSystemReadyCallback != null)
    {
      _fileSystemReadyCallback();
    }
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
  // Properties
  //---------------------------------------------------------------------

  /// The temporary workspace
  Workspace get tempWorkspace => _tempWorkspace;
  /// The created workspaces
  List<Workspace> get workspaces => _workspaces;

  //---------------------------------------------------------------------
  // Workspace
  //---------------------------------------------------------------------

  /**
   * Creates a new [Workspace].
   */
  Future<Workspace> _createWorkspace(String directoryName, [String name = ''])
  {
    Completer workspaceCreation = new Completer();

    _fileSystem.root.getDirectory(directoryName, options: {'create': true}, successCallback: (directoryEntry) {
      Workspace workspace = new Workspace(directoryEntry, name);

      workspaceCreation.complete(workspace);
    }, errorCallback: _onFileSystemError);

    return workspaceCreation.future;
  }

  /**
   * Creates a copy of a [Workspace] already present on the file system.
   */
  Future<Workspace> copyWorkspace(Workspace original, String name)
  {
    Completer workspaceCreation = new Completer();
    String newDirectoryName = _getNewDirectoryName();

    original._directory.copyTo(_fileSystem.root, newDirectoryName, (newDirectory) {
      Workspace copy = new Workspace(newDirectory, name);
      _workspaces.add(copy);

      // Create metadata
      String metadata = '{ "name": "$name" }';
      copy.saveMetadata(metadata).then((_) {
        workspaceCreation.complete(copy);
      });
    }, ApplicationFileSystem._onFileSystemError);

    return workspaceCreation.future;
  }

  /**
   * Loads a [Workspace] already present on the file system.
   */
  Future<Workspace> loadWorkspace(String name)
  {
    Completer workspaceLoaded = new Completer();
    int length = _workspaces.length;

    for (int i = 0; i < length; ++i)
    {
      Workspace workspace = _workspaces[i];

      if (name == workspace.name)
      {
        workspaceLoaded.complete(workspace);
      }
    }

    return workspaceLoaded.future;
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

            Workspace workspace = new Workspace(entry);

            if (entry.name == _tempWorkspaceName)
            {
              _tempWorkspace = workspace;
            }
            else
            {
              _workspaces.add(workspace);
            }
          }
        }

        // It isn't guaranteed that all results will be
        // returned so call the function until the length
        // of the result is zero
        _searchForWorkspaces(directoryReader);
      }
    });
  }

  /**
   * Gets a directory name based on the current time.
   *
   * This is just used so there aren't any naming collisions.
   */
  static String _getNewDirectoryName()
  {
    Date currentTime = new Date.now();
    return '${currentTime.millisecondsSinceEpoch}';
  }
}
