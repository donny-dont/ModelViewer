import 'dart:io';

/**
 * Writes the mesh file.
 */
Future<File> writeMesh(String fileName, List<int> data)
{
  Path filePath = new Path(fileName);
  File meshFile = new File.fromPath(filePath);

  Completer completer = new Completer();

  meshFile.open(FileMode.WRITE).then((RandomAccessFile file) {
    file.writeList(data, 0, data.length).then((writtenFile) {
      completer.complete(writtenFile);
    });
  });

  return completer.future;
}

/**
 * Reads the mesh file.
 */
Future<String> readMesh(String fileName)
{
  Path filePath = new Path(fileName);
  File meshFile = new File.fromPath(filePath);

  return meshFile.readAsString();
}

/**
 * Runs the conversion process.
 *
 * Takes the file specified in [inputFileName] and runs the
 * conversion process. The resulting mesh file is placed into
 * [outputFileName].
 */
Future<ProcessResult> runConversion(String inputFileName, String outputFileName)
{
  List<String> arguments = [ inputFileName, outputFileName ];
  return Process.run('bin/spectre_model.exe', arguments);
}

/**
 * Runs the websocket server.
 */
void main()
{
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);

  wsHandler.onOpen = (WebSocketConnection conn) {
    print('new connection');
    String originalFileName = '';
    String convertedFileName = '';

    conn.onMessage = (message) {
      if (originalFileName.isEmpty)
      {
        originalFileName = 'bin/output/$message';
        convertedFileName = '${originalFileName.substring(0, originalFileName.lastIndexOf('.'))}.mesh';
        print(convertedFileName);
      }
      else
      {
        // File is being sent
        writeMesh(originalFileName, message).then((_) {
          runConversion(originalFileName, convertedFileName).then((ProcessResult result) {
            if (result.exitCode == 0)
            {
              readMesh(convertedFileName).then((contents) {
                conn.send(contents);
              });
            }
          });
        });
      }
    };

    conn.onClosed = (int status, String reason) {
      print('closed with $status for $reason');
    };
  };

  server.listen('127.0.0.1', 8000);
}
