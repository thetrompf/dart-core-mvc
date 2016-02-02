/// The [ioc] library.
library ioc;

import 'dart:mirrors'
    show ClassMirror, MirrorSystem, MethodMirror, reflectClass, ParameterMirror;

part 'src/ioc/binding.dart';
part 'src/ioc/exceptions.dart';
part 'src/ioc/injector.dart';

final Map<Type, Binding> _abstractMap = {};
final Map<Type, Binding> _concreteMap = {};

Binding bind(Type type) => new _Binding(type);

final Symbol defaultConstructor = MirrorSystem.getSymbol("");
