part of ioc;

/// Binding object is the component that describes
/// the relation from typically an abstract [fromType] to
/// a concrete [toType] typically a concrete [Type] definition
/// or if an instantiated [Object] is provided it will with the current
/// implementation act like a singleton between request cycles.
///
/// In a future release if the [toType] is a [Function] is provided
/// to create instances it will be invoked upon every resolution.
abstract class Binding {
  /// The [Type] to bind from, typically an abstract [Type] is used.
  Type get fromType;

  /// The type to resolve to, if a [Type] is provided, the [Injector] is used
  /// to create the resolving type, if a non-[Type] [Object] is provided
  /// it will with the current implementation act like [Application]-wide singleton
  Object get toType;

  /// Bind the [fromType] to the [toType]
  Binding to(Object type);
}

/// The default IOC binding implementation.
class _Binding implements Binding {
  final Type fromType;
  Object _toType;
  Object get toType => _toType;

  _Binding(this.fromType);

  /// In a future release [Function] [toType]s will be supported.
  /// TODO: support [Function] [toType]s
  Binding to(Object type) {
    _toType = type;
    if (_toType is Type) {
      _abstractMap[fromType] = this;
    } else {
      _concreteMap[fromType] = this;
    }
    return this;
  }
}
