part of viewer;

/**
 * Contains a log of any compilation issues.
 */
class CompileLog
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  static final RegExp _errorExp = new RegExp(r"ERROR:\s+(\d+):(\d+):\s+('.*)");
  static final RegExp _warningExp = new RegExp(r"WARNING:\s+(\d+):(\d+):\s+('.*)");

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The number of errors
  int _errors;
  /// The number of warnings
  int _warnings;
  /// The compilation status
  DivElement _status;
  /// The error log
  TableSectionElement _errorLog;
  /// The warning log
  TableSectionElement _warningLog;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Initializes an instance of the [CompileLog] class.
   */
  CompileLog()
  {
    _errors = 0;
    _warnings = 0;

    _status = query('#compiler_status');
    assert(_status != null);

    _errorLog = query('#error_table');
    _warningLog = query('#warning_table');
  }

  //---------------------------------------------------------------------
  // UI methods
  //---------------------------------------------------------------------

  /**
   * Add to the log.
   */
  void addToLog(String source, String log)
  {
    print(log);

    Match match;
    match = _errorExp.firstMatch(log);

    if (match != null)
    {
      _errors++;

      List<String> groups = match.groups([0, 1, 2, 3]);

      _addToTable(_errorLog, source, groups);
    }

    match = _warningExp.firstMatch(log);

    if (match != null)
    {
      _warnings++;

      List<String> groups = match.groups([0, 1, 2, 3]);

      _addToTable(_warningLog, source, groups);
    }

    _displayStatus();
  }

  /**
   * Clears the compile log.
   */
  void clear()
  {
    _errors = 0;
    _warnings = 0;

    _errorLog.nodes.clear();
    _warningLog.nodes.clear();

    _displayStatus();
  }

  /**
   * Adds a value to the table.
   */
  void _addToTable(TableSectionElement table, String source, List<String> groups)
  {
    TableRowElement row = new TableRowElement();

    TableCellElement shader = new TableCellElement();
    shader.innerHTML = source;
    row.nodes.add(shader);

    TableCellElement location = new TableCellElement();
    location.innerHTML = '${groups[1]},${groups[2]}';
    row.nodes.add(location);

    TableCellElement message = new TableCellElement();
    message.innerHTML = groups[3];
    row.nodes.add(message);

    table.nodes.add(row);
  }

  /**
   * Changes the status being displayed.
   */
  void _displayStatus()
  {
    _status.innerHTML = '$_errors errors $_warnings warnings';
  }
}
