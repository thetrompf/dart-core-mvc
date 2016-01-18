part of logger;

/// The [Log] class represents a log entry
/// passed to the [Logger.write] method.
///
/// It is in its essence just a property bag
/// for logging information containing the log [level]
class Log {

  /// The [level] of the [Log] entry.
  final int level;

  /// The [message] of the [Log] entry.
  final Object message;

  /// The [group] of the [Log] entry.
  final String group;

  /// The [timestamp] of the [Log] entry.
  final DateTime timestamp;

  Log({this.level, this.message, this.group}) :
      timestamp = new DateTime.now();
}
