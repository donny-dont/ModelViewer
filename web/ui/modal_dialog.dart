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
 * A [ModalDialog] for loading files.
 */
class LoadDialog extends ModalDialog
{
  /**
   * Creates an instance of the [LoadDialog] class.
   */
  LoadDialog(String id)
    : super(id)
  {

  }
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
