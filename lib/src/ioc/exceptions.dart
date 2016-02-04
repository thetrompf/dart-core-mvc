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

/// This exception is thrown if a [Binding] is bound to
/// a type that causes resolving of the type go into infinite loop.
class CyclicDependencyException implements IocException {
  final String message;

  const CyclicDependencyException([this.message]);

  String toString() {
    if (message == null) {
      return 'CyclicDependencyException';
    }
    return 'CyclicDependencyException: $message';
  }
}

/// This exception is throw if a [Binding] is bound to
/// a [Type] that is not a subtype of the [Binding.fromType].
class IncompatibleBindingException implements IocException {
  final String message;

  const IncompatibleBindingException([this.message]);

  String toString() {
    if (message == null) {
      return 'IncompatibleBindingException';
    }
    return 'IncompatibleBindingException: $message';
  }
}
