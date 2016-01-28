part of logger;

/// The base [Logger] class
/// that provides the interface of a logger like the `console` object in a
/// javascript vm with a few additions like [success] and [verbose].
///
/// This base implementation of the logging methods
/// filter outs the [Log] entries if the level configured is lower than
/// level of the [Log] entry to be written.
///
/// Extending classes must implement their own [write] method.
abstract class Logger {
  /// The level mask of the logger.
  final int level;

  /// The group to provide in every log entry written by this [Logger].
  final String group;

  Logger({this.level: INFO_LEVEL, this.group: null});

  /// Write [msg] in log-level ERROR if the ERROR_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void error(Object msg) {
    if ((level & ERROR_MASK) != ERROR_MASK) {
      return;
    }
    write(new Log(level: ERROR_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level WARNING if the WARNING_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void warn(Object msg) {
    if ((level & WARNING_MASK) != WARNING_MASK) {
      return;
    }
    write(new Log(level: WARNING_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level SUCCESS if the SUCCESS_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void success(Object msg) {
    if ((level & SUCCESS_MASK) != SUCCESS_MASK) {
      return;
    }
    write(new Log(level: SUCCESS_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level LOG if the LOG_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void log(Object msg) {
    if ((level & LOG_MASK) != LOG_MASK) {
      return;
    }
    write(new Log(level: LOG_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level INFO if the INFO_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void info(Object msg) {
    if ((level & INFO_MASK) != INFO_MASK) {
      return;
    }
    write(new Log(level: INFO_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level DEBUG if the DEBUG_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void debug(Object msg) {
    if ((level & DEBUG_MASK) != DEBUG_MASK) {
      return;
    }
    write(new Log(level: DEBUG_MASK, message: msg, group: group));
  }

  /// Write [msg] in log-level VERBOSE if the VERBOSE_MASK
  /// is present in [level] mask other wise do not write the [Log] entry.
  void verbose(Object msg) {
    if ((level & VERBOSE_MASK) != VERBOSE_MASK) {
      return;
    }
    write(new Log(level: VERBOSE_MASK, message: msg, group: group));
  }

  /// This method writes the [Log] entries created by logging
  /// methods of this [Logger] it must be implemented by the extending classes.
  void write(Log log);
}
