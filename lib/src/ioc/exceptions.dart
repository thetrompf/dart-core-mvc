part of ioc;

/// The IOC base exception.
abstract class IocException implements Exception {}

/// This exception is thrown if the [Injector] couldn't find
/// a default constructor (unnamed) on the [Type] it's currently
/// resolving.
class NoDefaultConstructorFoundException implements IocException {
  /// The [type] that couldn't be found a default constructor on.
  final String type;

  const NoDefaultConstructorFoundException(this.type);

  String toString() {
    return '';
  }
}
