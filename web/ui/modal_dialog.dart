part of viewer;

/// Callback type for when a file dialog is submitted.
typedef void FileDialogSubmitEvent(String name);

/**
 * A basic modal dialog to overlay over the application.
 */
class ModalDialog
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The class for an open dialog.
  static const String _openedDialogClass = 'modal_dialog_opened';
  /// The class for a closed dialog.
  static const String _closedDialogClass = 'modal_dialog_closed';

  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The root element containing the modal dialog.
  DivElement _element;

  /**
   * Creates an instance of the [ModalDialog] class from the given [id].
   */
  ModalDialog(String id)
  {
    _element = query(id);

    // A hidden class is used so the dialogs don't fade out when
    // the page is opened. Remove the hidden class right away
    // so fading in works as expected.
    _element.classes.remove(_ElementNames.hiddenClass);
  }

  /// Whether the modal dialog is visible.
  bool get visible => _element.classes.contains(_openedDialogClass);

  /**
   * Shows the modal dialog.
   */
  void show()
  {
    _element.classes.remove(_closedDialogClass);
    _element.classes.add(_openedDialogClass);
  }

  /**
   * Hides the modal dialog.
   */
  void hide()
  {
    _element.classes.remove(_openedDialogClass);
    _element.classes.add(_closedDialogClass);
  }

  /**
   * Callback for closing the dialog.
   */
  void _onHide(_)
  {
    hide();
  }
}

/**
 * A [ModalDialog] that can be closed by clicking outside of its area.
 */
class SimpleModalDialog extends ModalDialog
{
  /**
   * Creates an instance of the [SimpleModalDialog] class.
   */
  SimpleModalDialog(String id)
    : super(id)
  {
    DivElement container = _element.query('div');

    container.on.click.add((e) {
      e.stopPropagation();
    });

    _element.on.click.add(_onHide);
  }
}

/**
 * A [ModalDialog] for interacting with the filesystem.
 */
class FileSystemDialog extends ModalDialog
{
  /// The class for file selection.
  static const String _fileSelectedClass = 'file_selected';

  /// The file system for the application.
  ApplicationFileSystem _fileSystem;
  /// The rows containing the file information.
  List<TableRowElement> _files;
  /// Callback for when the dialog is submitted.
  FileDialogSubmitEvent submitCallback;
  /// The currently selected file.
  int _selectedFile;

  /**
   * Creates an instance of the [LoadDialog] class.
   */
  FileSystemDialog(String id, ApplicationFileSystem fileSystem)
    : super(id)
  {
    _fileSystem = fileSystem;
    _files = new List<TableRowElement>();

    DivElement submit = _element.query(_ElementNames.submitButtonClassName);
    submit.on.click.add(_onSubmit);

    DivElement cancel = _element.query(_ElementNames.cancelButtonClassName);
    cancel.on.click.add(_onHide);
  }

  /**
   * Creates a list of all the workspaces currently available.
   *
   * Will ignore the current workspace unless specified.
   */
  void _createFileList([bool ignoreCurrent = true])
  {
    TableElement table = _element.query('table');
    table.nodes.clear();

    _selectedFile = -1;
    _files.clear();
    int length = _fileSystem.workspaces.length;

    for (int i = 0; i < length; ++i)
    {
      TableCellElement cell;
      TableRowElement row = new TableRowElement();
      table.nodes.add(row);
      _files.add(row);

      row.on.click.add((_) {
        _selectFile(i);
      });

      Workspace workspace = _fileSystem.workspaces[i];

      cell = new TableCellElement();
      cell.innerHTML = workspace.name;
      row.nodes.add(cell);

      cell = new TableCellElement();
      cell.innerHTML = 'Dec 23rd';
      row.nodes.add(cell);
    }
  }

  /**
   * Selects a workspace.
   */
  void _selectFile(int index)
  {
    _selectedFile = index;

    int length = _files.length;

    for (int i = 0; i < length; ++i)
    {
      TableRowElement row = _files[i];

      if (index == i)
      {
        row.classes.add(_fileSelectedClass);
      }
      else
      {
        row.classes.remove(_fileSelectedClass);
      }
    }
  }

  void _onSubmit(_) {}
}

/**
 * A [ModalDialog] for loading files.
 */
class LoadDialog extends FileSystemDialog
{
  /**
   * Creates an instance of the [LoadDialog] class.
   */
  LoadDialog(String id, ApplicationFileSystem fileSystem)
    : super(id, fileSystem);

  /**
   * Shows the modal dialog.
   */
  void show()
  {
    super.show();

    _createFileList();
  }

  /**
   * Callback for loading a file.
   */
  void _onSubmit(_)
  {
    if ((_selectedFile != -1) && (submitCallback != null))
    {
      String name = _fileSystem.workspaces[_selectedFile].name;

      submitCallback(name);
    }
  }
}

/**
 * A [ModalDialog] for saving files.
 */
class SaveDialog extends FileSystemDialog
{
  /// Input element containing the name of the workspace.
  InputElement _nameElement;

  /**
   * Creates an instance of the [SaveDialog] class.
   */
  SaveDialog(String id, ApplicationFileSystem fileSystem)
    : super(id, fileSystem)
  {
    _nameElement = _element.query('input');
  }

  /**
   * Callback for saving the file.
   */
  void _onSubmit(_)
  {
    String value = _nameElement.value;

    if (value.isEmpty)
    {
      return;
    }

    // Make sure the name isn't already in use
    for (Workspace workspace in _fileSystem.workspaces)
    {
      if (workspace.name == _nameElement.value)
      {
        return;
      }
    }

    if (submitCallback != null)
    {
      submitCallback(_nameElement.value);
    }
  }
}
