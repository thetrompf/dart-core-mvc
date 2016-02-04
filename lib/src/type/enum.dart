part of type;

/// Basic [Enum] implementation inspired by how Enums work in Java
/// This implementation allows doing advanced stuff like creating an [Enum]
/// from the string key, which is useful when using enums to represent fixed data
/// sent over network, modeled as an [Enum] type.
///
/// Furthermore this also allows operator overloading which can be useful for comparison.
///
///     var _logLevelMirror = reflectClass(LogLevel);
///     class LogLevel extends Enum<int> {
///
///       static const SILENT = const LogLevel(0x00);
///       static const ERROR = const LogLevel(0x01);
///       static const WARNING = const LogLevel(0x02);
///       static const LOG = const LogLevel(0x04);
///       static const DEBUG = const LogLevel(0x08);
///
///       const LogLevel(int value) : super(value);
///
///       bool operator ==(other) {
///         if(other is int) {
///           return value == other;
///         }
///         return super==(other);
///       }
///
///       LogLevel operator &(other) {
///         if(other is int) {
///           return new LogLevel(value & other);
///         }
///         if(other is Enum<int>) {
///           return new LogLevel(value & other.value);
///         }
///         return super&(other);
///       }
///
///       LogLevel operator |(other) {
///         if(other is int) {
///           return new LogLevel(value | other);
///         }
///         if(other is Enum<int>) {
///           return new LogLevel(value | other.value);
///         }
///         return super|(other);
///       }
///
///       factory LogLevel.fromString(String type) => super.fromString(type, _logLevelMirror);
///
///       String toString() => super.enumToString(_logLevelMirror);
///     }
///
///     var error = LogLevel.ERROR;
///     var warning = LogLevel.WARNING;
///
///     var result = error | warning;
///     print(result & error == error); // true
///
abstract class Enum<T> {
  /// The value to compare with.
  final T _value;
  T get value => _value;

  /// Constructs an enum based on [_value].
  const Enum(this._value);

  /// Create an enum instance based on the metadata from [mirror]
  /// to find and return declared enum with name of [key].
  /// If non found an [UnsupportedError] is thrown.
  factory Enum.fromString(String key, ClassMirror mirror) {
    var symbolType = MirrorSystem.getSymbol(key);
    if (mirror.declarations.containsKey(symbolType)) {
      var declaration = mirror.staticMembers[symbolType];
      if (declaration.isStatic && declaration.isGetter) {
        return mirror.getField(symbolType).reflectee;
      }
    }
    throw new UnsupportedError("$key is not a member of enum: " +
        MirrorSystem.getName(mirror.simpleName));
  }

  /// Find the member name from [value] based on the
  /// metadata provided by [mirror].
  ///
  ///     var _enumTestMirror = reflectClass(EnumTest);
  ///     class EnumTest extends Enum<String> {
  ///       String toString() => super.enumToString(_enumTestMirror);
  ///     }
  String enumToString(ClassMirror mirror) {
    for (final symbol in mirror.staticMembers.keys) {
      final val = mirror.staticMembers[symbol];
      if (val.isStatic && val.isGetter) {
        var reflectedValue = mirror.getField(symbol).reflectee as Enum;
        if (reflectedValue._value == _value) {
          return MirrorSystem.getName(mirror.simpleName) +
              '.' +
              MirrorSystem.getName(symbol);
        }
      }
    }
    throw new StateError(
        "Couldn't find string representation of this enum member");
  }

  /// Make enum types comparable by value.
  bool operator ==(Enum other) => _value == other._value;
}
