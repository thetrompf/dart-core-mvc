part of type;

abstract class Enum<T> {
  final T _value;
  T get value => _value;

  const Enum(this._value);

  factory Enum.fromString(String type, ClassMirror mirror) {
    var symbolType = MirrorSystem.getSymbol(type);
    if (mirror.declarations.containsKey(symbolType)) {
      var declaration = mirror.staticMembers[symbolType];
      if (declaration.isStatic && declaration.isGetter) {
        return mirror.getField(symbolType).reflectee;
      }
    }
    throw new UnsupportedError("$type is not a member of enum: " +
        MirrorSystem.getName(mirror.simpleName));
  }

  String enumToString(ClassMirror mirror) {
    for (final symbol in mirror.staticMembers.keys) {
      final val = mirror.staticMembers[symbol];
      if (val.isStatic && val.isGetter) {
        var reflectedValue = mirror.getField(symbol).reflectee as Enum;
        if (reflectedValue._value == _value) {
          return MirrorSystem.getName(symbol);
        }
      }
    }
    throw new StateError(
        "Couldn't find string representation of this enum member");
  }

  bool operator ==(Enum other) => _value == other._value;
}
