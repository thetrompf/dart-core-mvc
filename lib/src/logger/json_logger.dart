part of logger;

/// A JSON implementation of the [Logger] interface.
/// Every [Log] entry is converted to JSON strings and written to
/// this [output].
class JsonLogger extends Logger {
  /// The sink
  final StringSink output;

  JsonLogger({int level: INFO_LEVEL, String group: null, output: null})
      : super(level: level, group: group),
        output = output ?? stdout;

  @override
  void write(Log log) {
    String message = null;

    try {
      message = JSON.encode(log.message);
    } catch (e) {
      message = 'Encoding error of message: ' + log.message.toString();
    }

    Map logObj = {
      'level': log.level,
      'group': log.group,
      'message': message,
      'timestamp': log.timestamp.toString()
    };

    output.write(JSON.encode(logObj) + "\n");
  }
}
