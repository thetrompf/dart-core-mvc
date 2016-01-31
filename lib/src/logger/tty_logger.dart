part of logger;

/// The ansi colors available.
enum Color { BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE }

/// The style codes available, including the reset style.
enum Style { RESET, BOLD }

int _LARGEST_GROUP_LENGTH_SEEN = 0;

/// The ansi code for resetting the terminal
const int RESET_CODE = 0;

/// The ansi color code for bold styled text.
const int BOLD_STYLE_CODE = 1;

// The ansi color codes for foreground colors.
/// ANSI color code for black foreground.
const int BLACK_FOREGROUND_CODE = 30;

/// ANSI color code for red foreground.
const int RED_FOREGROUND_CODE = 31;

/// ANSI color code for green foreground.
const int GREEN_FOREGROUND_CODE = 32;

/// ANSI color code for yellow foreground.
const int YELLOW_FOREGROUND_CODE = 33;

/// ANSI color code for blue foreground.
const int BLUE_FOREGROUND_CODE = 34;

/// ANSI color code for magenta foreground.
const int MAGENTA_FOREGROUND_CODE = 35;

/// ANSI color code for cyan foreground.
const int CYAN_FOREGROUND_CODE = 36;

/// ANSI color code for white foreground.
const int WHITE_FOREGROUND_CODE = 37;

// The ansi color codes for background colors.
/// ANSI color code for black background.
const int BLACK_BACKGROUND_CODE = 40;

/// ANSI color code for red background.
const int RED_BACKGROUND_CODE = 41;

/// ANSI color code for green background.
const int GREEN_BACKGROUND_CODE = 42;

/// ANSI color code for yellow background.
const int YELLOW_BACKGROUND_CODE = 43;

/// ANSI color code for blue background.
const int BLUE_BACKGROUND_CODE = 44;

/// ANSI color code for magenta background.
const int MAGENTA_BACKGROUND_CODE = 45;

/// ANSI color code for cyan background.
const int CYAN_BACKGROUND_CODE = 46;

/// ANSI color code for white background.
const int WHITE_BACKGROUND_CODE = 47;

/// Background color map from [Color] to ansi color codes.
final BACKGROUND_COLOR_CODES = <Color, int>{
  Color.BLACK: BLACK_BACKGROUND_CODE,
  Color.RED: RED_BACKGROUND_CODE,
  Color.GREEN: GREEN_BACKGROUND_CODE,
  Color.YELLOW: YELLOW_BACKGROUND_CODE,
  Color.BLUE: BLUE_BACKGROUND_CODE,
  Color.MAGENTA: MAGENTA_BACKGROUND_CODE,
  Color.CYAN: CYAN_BACKGROUND_CODE,
  Color.WHITE: WHITE_BACKGROUND_CODE,
};

/// Foreground color map [Color] to ansi color codes.
final FOREGROUND_COLOR_CODES = <Color, int>{
  Color.BLACK: BLACK_FOREGROUND_CODE,
  Color.RED: RED_FOREGROUND_CODE,
  Color.GREEN: GREEN_FOREGROUND_CODE,
  Color.YELLOW: YELLOW_FOREGROUND_CODE,
  Color.BLUE: BLUE_FOREGROUND_CODE,
  Color.MAGENTA: MAGENTA_FOREGROUND_CODE,
  Color.CYAN: CYAN_FOREGROUND_CODE,
  Color.WHITE: WHITE_FOREGROUND_CODE,
};

/// The [AnsiPen] entry point for configuring a color [Pen].
Pen get AnsiPen => new _Pen();

/// Override the color variables for different colors per log level
/// when using the [TtyLogger].

/// The color used when formatting [Log] entries in [ERROR_MASK] [Log.level].
Pen ERROR_COLOR = AnsiPen.white.bg.red;

/// The color used when formatting [Log] entries in [WARNING_MASK] [Log.level].
Pen WARNING_COLOR = AnsiPen.bg.red.bold;

/// The color used when formatting [Log] entries in success [Log.level].
Pen SUCCESS_COLOR = AnsiPen.green;

/// The color used when formatting [Log] entries in log [Log.level].
Pen LOG_COLOR = AnsiPen;

/// The color used when formatting [Log] entries in info [Log.level].
Pen INFO_COLOR = AnsiPen.blue;

/// The color used when formatting [Log] entries in debug [Log.level].
Pen DEBUG_COLOR = AnsiPen.yellow;

/// The color used when formatting [Log] entries in verbose [Log.level].
Pen VERBOSE_COLOR = AnsiPen.magenta;

/// The color used when formatting [Log.timestamp].
Pen TIMESTAMP_COLOR = AnsiPen.cyan;

/// The Pen interface emulate a colored pen in TTY context.
/// You can configure a [Pen] by calling the color properties,
/// when the [Pen] in configured, it has the interface of a simple [Function]
/// by utilizing the [call] method.
///
/// The TTY Logger provides an implementation of the [Pen] interface called [AnsiPen]
/// consider using that as a starting point for configuring a [Pen]
///
///     Pen pen = AnsiPen.red.bg.black.bold;
///     print(pen('Red bold text on black background'));
///
/// @todo Move all console and ANSI helpers into a utility library, or maybe even a library of its own.
abstract class Pen {
  /// The [foreground] [Color] of this [Pen].
  Color get foreground;

  /// The [background] [Color] of this [Pen].
  Color get background;

  /// Whether or not the [Pen] writes in [bold].
  bool get isBold;

  /// Sets the color of the [Pen] to [black].
  Pen get black;

  /// Sets the color of the [Pen] to [red].
  Pen get red;

  /// Sets the color of the [Pen] to [green].
  Pen get green;

  /// Sets the color of the [Pen] to [yellow].
  Pen get yellow;

  /// Sets the color of the [Pen] to [blue].
  Pen get blue;

  /// Sets the color of the [Pen] to [magenta].
  Pen get magenta;

  /// Sets the color of the [Pen] to [cyan].
  Pen get cyan;

  /// Sets the color of the [Pen] to [white].
  Pen get white;

  /// Configure the [Pen] to set the next color as [foreground] color.
  Pen get fg;

  /// Configure the [Pen] to set the next color as [background] color.
  Pen get bg;

  /// Set the style of the text to [bold].
  Pen get bold;

  /// Output [str] styled with the current configuration of this [Pen].
  String call(String str);
}

/// The [TtyLogger] is mostly meant for development
/// when logging the output of the server running to the terminal.
///
/// Consider using a parsable [Logger] implementation e.g. [JsonLogger]
/// in production.
class TtyLogger extends Logger {
  /// The sink to write the [output] to.
  final StringSink output;

  /// Whether or not colors are enabled.
  final bool color;

  /// Which color to use when formatting the [group].
  final Pen groupColor;

  TtyLogger(
      {int level: INFO_LEVEL,
      String group,
      StringSink output,
      bool this.color: true,
      Pen this.groupColor})
      : super(level: level, group: group),
        output = output ?? stdout {
    if (group != null) {
      _LARGEST_GROUP_LENGTH_SEEN =
          max(_LARGEST_GROUP_LENGTH_SEEN, group.length);
    }
  }

  /// Write [Log] entries to [output] stream.
  void write(Log log) {
    var sb = new StringBuffer();
    sb.write(formatTimestamp(log.timestamp));
    sb.write(formatGroup(log.group));
    sb.write("[");
    var levelStr = levelToString(log.level);
    sb.write(formatLevel(log.level, levelStr));
    sb.write("] ");
    var padding = 7 - levelStr.length;
    if (padding > 0) {
      sb.write(" " * padding);
    }
    sb.write(formatMessage(log.message, log.level, sb));
    output.write(sb.toString() + "\n");
  }

  String levelToString(int level) {
    switch (level) {
      case ERROR_MASK:
        return "ERROR";
      case WARNING_MASK:
        return "WARNING";
      case SUCCESS_MASK:
        return "SUCCESS";
      case LOG_MASK:
        return "LOG";
      case INFO_MASK:
        return "INFO";
      case DEBUG_MASK:
        return "DEBUG";
      case VERBOSE_MASK:
        return "VERBOSE";
      default:
        throw new UnsupportedError("Unsupported log level: $level");
    }
  }

  /// Format the [timestamp] that is written to the [output] stream.
  String formatTimestamp(DateTime timestamp) {
    return "[" + colorize(timestamp.toString(), TIMESTAMP_COLOR) + "] ";
  }

  /// Format the [group] that is written to the [output] stream.
  String formatGroup(String group) {
    return "[" +
        colorize(group, groupColor) +
        "] " +
        (" " * (_LARGEST_GROUP_LENGTH_SEEN - group.length));
  }

  /// Apply [color] to the [string] that is written to the [output] stream.
  /// if colors are disabled or no [color] is provided
  /// the [string] is just returned without colors applied..
  String colorize(String string, Pen color) {
    if (!this.color || color == null) {
      return string;
    }

    return color(string);
  }

  /// Apply the styles of the [level] to [msg].
  /// if no [msg] is provided the name of the string representation
  /// of the log-[level is used as [msg].
  String formatLevel(int level, String msg) {
    switch (level) {
      case ERROR_MASK:
        return colorize(msg, ERROR_COLOR);
      case WARNING_MASK:
        return colorize(msg, WARNING_COLOR);
      case SUCCESS_MASK:
        return colorize(msg, SUCCESS_COLOR);
      case LOG_MASK:
        return colorize(msg, LOG_COLOR);
      case INFO_MASK:
        return colorize(msg, INFO_COLOR);
      case DEBUG_MASK:
        return colorize(msg, DEBUG_COLOR);
      case VERBOSE_MASK:
        return colorize(msg, VERBOSE_COLOR);
      default:
        throw new UnsupportedError("Unsupported log level: $level");
    }
  }

  /// Format this [message] object with styles of this log-[level].
  /// if [message] contains multiline content
  /// The [Log] information is applied to every line of this [message]
  /// which [sb] provides a string representation of.
  String formatMessage(Object message, int level, StringBuffer sb) {
    return message
        .toString()
        .split("\n")
        .map((e) => formatLevel(level, e))
        .join("\n" + sb.toString());
  }
}

class _Pen implements Pen {
  final Color foreground;
  final Color background;
  final bool isBold;

  bool _settingBackground = false;
  bool get _settingForeground => !_settingBackground;

  _Pen(
      {this.foreground: null,
      this.background: null,
      this.isBold: false,
      settingBackground: false})
      : _settingBackground = settingBackground;

  Pen get bg {
    _settingBackground = true;
    return this;
  }

  Pen get fg {
    _settingBackground = false;
    return this;
  }

  Pen get black => _setColor(Color.BLACK);
  Pen get red => _setColor(Color.RED);
  Pen get green => _setColor(Color.GREEN);
  Pen get yellow => _setColor(Color.YELLOW);
  Pen get blue => _setColor(Color.BLUE);
  Pen get magenta => _setColor(Color.MAGENTA);
  Pen get cyan => _setColor(Color.CYAN);
  Pen get white => _setColor(Color.WHITE);

  Pen get bold {
    if (!isBold) {
      return new _Pen(
          foreground: foreground,
          background: background,
          isBold: true,
          settingBackground: _settingForeground);
    }
    return this;
  }

  Pen _setColor(Color color) {
    if (_settingForeground) {
      if (foreground != color) {
        return new _Pen(
            foreground: color,
            background: background,
            isBold: isBold,
            settingBackground: _settingBackground);
      }
      return this;
    } else {
      if (background != color) {
        return new _Pen(
            foreground: foreground,
            background: color,
            isBold: isBold,
            settingBackground: _settingBackground);
      }
      return this;
    }
  }

  String call(String str) {
    if (str == null) {
      return '';
    }

    var styles = [];
    if (isBold) {
      styles.add(BOLD_STYLE_CODE);
    }

    if (foreground != null) {
      styles.add(FOREGROUND_COLOR_CODES[foreground]);
    }
    if (background != null) {
      styles.add(BACKGROUND_COLOR_CODES[background]);
    }

    var sb = new StringBuffer("\x1b[0m");

    if (styles.length > 0) {
      sb.write("\x1b[");
      sb.write(styles.join(';'));
      sb.write('m');
    }

    sb.write(str);

    sb.write("\x1b[0m");
    return sb.toString();
  }
}
