/// The [logger] library contains the base [Logger]
/// interface for making custom logging mechanism. The interface
/// is compatible with the `console` interface known from javascript.
///
/// A [JsonLogger] implementation is available, usable used in production
/// for parsable logs, makes it easy to forward the logs to services such
/// as LogStash.
///
/// Furthermore is [TtyLogger] implementation provided, its great for development
/// when running the framework directly from command-line. It supports groups and colors
/// which makes it easy for the eyes to find exactly the entries you are looking for.
///
/// In a future release their might be included a search interface from
/// command-line.
library logger;

import 'dart:io' show stdout,stderr;
import 'dart:convert' show JSON;
import 'dart:math' show max;

part 'src/logger/logger.dart';
part 'src/logger/log.dart';
part 'src/logger/json_logger.dart';
part 'src/logger/tty_logger.dart';

/// The error mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.error] is written.
const int ERROR_MASK = 0x01;
/// The warning mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.warn] is written.
const int WARNING_MASK = 0x02;
/// The success mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.success] is written.
const int SUCCESS_MASK = 0x04;
/// The log mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.log] is written.
const int LOG_MASK = 0x08;
/// The info mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.info] is written.
const int INFO_MASK = 0x10;
/// The debug mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.debug] is written.
const int DEBUG_MASK = 0x20;
/// The verbose mask, if this mask is present in [Logger.level]
/// then [Log] entries logged using [Logger.verbose] is written.
const int VERBOSE_MASK = 0x40;

/// The SILENT log level, if this level is used, no [Log] entries
/// are written.
const int SILENT_LEVEL= 0x00;
/// The ERROR log level, this is a preset for only writing
/// [Log] entries with [ERROR_MASK] [Logger.level].
const int ERROR_LEVEL = SILENT_LEVEL | ERROR_MASK;
/// The WARNING log level, this is a preset for only-writing
/// [Log] entries within the range of [ERROR_LEVEL] but including [WARNING_MASK].
const int WARNING_LEVEL = ERROR_LEVEL | WARNING_MASK;
/// The SUCCESS log level, this is a preset for only writing
/// [Log] entries within the range of [WARNING_LEVEL] but including [SUCCESS_MASK].
const int SUCCESS_LEVEL = WARNING_LEVEL | SUCCESS_MASK;
/// The LOG level, this is a preset for only writing
/// [Log] entries within the range of [SUCCESS_LEVEL] but including [LOG_MASK]
const int LOG_LEVEL = SUCCESS_LEVEL | LOG_MASK;
/// The INFO log level, this is a preset for only writing
/// [Log] entries within the range of [LOG_LEVEL] but including [INFO_MASK]
const int INFO_LEVEL = LOG_LEVEL | INFO_MASK;
/// The DEBUG log level, this is a preset for only writing
/// [Log] entries within the range of [INFO_LEVEL] but including [DEBUG_MASK]
const int DEBUG_LEVEL = INFO_LEVEL | DEBUG_MASK;
/// The VERBOSE log level, this is a preset for only writing
/// all [Log] entries.
const int VERBOSE_LEVEL = DEBUG_LEVEL | VERBOSE_MASK;
