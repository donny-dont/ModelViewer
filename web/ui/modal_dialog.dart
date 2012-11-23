part of viewer;

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
  }

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

  /**
   * Creates an instance of the [LoadDialog] class.
   */
  FileSystemDialog(String id, ApplicationFileSystem fileSystem)
    : super(id)
  {
    _files = new List<TableRowElement>();

    DivElement submit = query(_ElementNames.submitButtonClassName);
    submit.on.click.add(_onSubmit);

    DivElement cancel = query(_ElementNames.cancelButtonClassName);
    cancel.on.click.add(_onHide);
  }

  /**
   * Shows the modal dialog.
   */
  void show()
  {
    super.show();

    _createFileList();
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

    int length = 3;

    for (int i = 0; i < length; ++i)
    {
      TableCellElement cell;
      TableRowElement row = new TableRowElement();
      table.nodes.add(row);
      _files.add(row);

      row.on.click.add((_) {
        _selectFile(i);
      });

      cell = new TableCellElement();
      cell.innerHTML = 'Testing';
      row.nodes.add(cell);

      cell = new TableCellElement();
      cell.innerHTML = 'Dec 23rd';
      row.nodes.add(cell);
    }
  }

  void _selectFile(int index)
  {
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

  void _onSubmit(_) { }
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
}

/**
 * A [ModalDialog] for saving files.
 */
class SaveDialog extends ModalDialog
{
  /// Input element containing the name of the workspace.
  InputElement _nameElement;

  /**
   * Creates an instance of the [SaveDialog] class.
   */
  SaveDialog(String id)
    : super(id)
  {
    DivElement save = query(_ElementNames.submitButtonClassName);
    save.on.click.add(_onSave);

    DivElement cancel = query(_ElementNames.cancelButtonClassName);
    cancel.on.click.add(_onHide);

    _nameElement = _element.query('input');
    print(_nameElement.value);
  }

  /**
   * Callback for saving the file.
   */
  void _onSave(_)
  {
    print(_nameElement.value);
  }
}
