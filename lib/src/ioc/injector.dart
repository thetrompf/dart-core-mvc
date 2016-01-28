part of ioc;

/// The dependency [Injector] is a powerful tool
/// to load instances of object through out the application
/// when the instances are configured the same way.
abstract class Injector {
  factory Injector() = DefaultInjector;

  /// Resolve a [type] defined through [Binding]s and
  /// return an instance of it.
  /// If no resolution found, an IocException will be thrown.
  /// See the [exceptions.dart] for specific more exceptions
  /// that can be thrown.
  Object getType(Type type);
}

/// The [DefaultInjector] implementation is
/// kept simple, so it only supports constructor injections
/// feel free to extend the functionality of this class or simply
/// implement a totally different [Injector] for full control of the
/// [Application]s class instance lifecycles and configurations.
class DefaultInjector implements Injector {
  DefaultInjector();

  Object getType(Type type) {
    if (_concreteMap.containsKey(type)) {
      return _concreteMap[type].toType;
    }

    if (_abstractMap.containsKey(type)) {
      return getType(_abstractMap[type].toType);
    }

    final ClassMirror reflectedClass = reflectClass(type);
    final MethodMirror constructor = getDefaultConstructor(reflectedClass);
    final List params = resolveParameters(constructor.parameters);

    return reflectedClass.newInstance(defaultConstructor, params).reflectee;
  }

  /// Resolve the default constructor of the [reflectedClass].
  MethodMirror getDefaultConstructor(ClassMirror reflectedClass) {
    return reflectedClass.declarations.values.firstWhere(
        (e) => e is MethodMirror &&
            e.isConstructor &&
            e.constructorName == defaultConstructor, orElse: () {
      throw new NoDefaultConstructorFoundException(
          MirrorSystem.getName(reflectedClass.simpleName));
    });
  }

  /// Resolve the positional [parameters].
  /// TODO: implement resolving of named parameters,
  ///       skip resolving of optional parameters/paramters with default values
  ///       if no configuration is provided.
  List resolveParameters(List<ParameterMirror> parameters) {
    final resolvedParameters = [];
    for (final param in parameters) {
      resolvedParameters.add(getType(param.type.reflectedType));
    }
    return resolvedParameters;
  }
}
