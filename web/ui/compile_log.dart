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
  /// A mapping of error and warning line numbers.
  Map<String, Map<String, List<int>>> _compilationIssues;
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

    _compilationIssues = new Map<String, Map<String, List<int>>>();
    _compilationIssues['Vertex'] = new Map<String, List<int>>();
    _compilationIssues['Fragment'] = new Map<String, List<int>>();
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Line numbers for vertex shader errors.
  List<int> get vertexShaderErrorLines => _compilationIssues['Vertex']['Errors'];
  /// Line number for vertex shader warnings.
  List<int> get vertexShaderWarningLines => _compilationIssues['Vertex']['Warnings'];

  /// Line numbers for fragment shader errors.
  List<int> get fragmentShaderErrorLines => _compilationIssues['Fragment']['Errors'];
  /// Line number for fragment shader warnings.
  List<int> get fragmentShaderWarningLines => _compilationIssues['Fragment']['Warnings'];

  //---------------------------------------------------------------------
  // UI methods
  //---------------------------------------------------------------------

  /**
   * Add to the log.
   */
  void addToLog(String source, String log)
  {
    Match match;
    match = _errorExp.firstMatch(log);

    Map issues = _compilationIssues[source];
    List<int> errors = new List<int>();
    List<int> warnings = new List<int>();

    if (match != null)
    {
      _errors++;

      List<String> groups = match.groups([0, 1, 2, 3]);

      int lineNumber = Math.parseInt(groups[2]) - 1;
      errors.add(lineNumber);

      _addToTable(_errorLog, source, groups);
    }

    match = _warningExp.firstMatch(log);

    if (match != null)
    {
      _warnings++;

      List<String> groups = match.groups([0, 1, 2, 3]);

      int lineNumber = Math.parseInt(groups[2]) - 1;
      warnings.add(lineNumber);

      _addToTable(_warningLog, source, groups);
    }

    issues['Errors'] = errors;
    issues['Warnings'] = warnings;

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
    int lineNumber = Math.parseInt(groups[2]) - 1;
    location.innerHTML = '${groups[1]},${lineNumber}';
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
