/// The [ioc] library.
library ioc;

import 'dart:mirrors'
    show
        ClassMirror,
        MethodMirror,
        MirrorSystem,
        ParameterMirror,
        reflectClass,
        reflectType;

part 'src/ioc/binding.dart';
part 'src/ioc/exceptions.dart';
part 'src/ioc/injector.dart';

final Map<Type, Binding> _abstractMap = {};
final Map<Type, Binding> _concreteMap = {};

Map<Type, Binding> get abstractMapCopy => new Map.from(_abstractMap);
Map<Type, Binding> get concreteMapCopy => new Map.from(_concreteMap);

Binding bind(Type type) => new _Binding(type);

final Symbol defaultConstructor = MirrorSystem.getSymbol("");
