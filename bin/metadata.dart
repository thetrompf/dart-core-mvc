import 'dart:mirrors';

import 'package:resem.pl/mvc.dart' show Controller;
import 'package:resem.pl/router.dart' show Route;
import 'package:resem.pl/action_filter.dart';
import 'dart:async';

Iterable<Object> getAllClassMetadata(ClassMirror classMirror) {
  return classMirror.metadata
      .map((InstanceMirror im) => im.reflectee);
}

Iterable<Object> getClassMetadata(ClassMirror classMirror, TypeMirror typeMirror) {
  return classMirror.metadata
      .where((InstanceMirror im) => im.type.isSubtypeOf(typeMirror))
      .map((InstanceMirror im) => im.reflectee);
}

Iterable<Object> getAllPropertyMetadata(MethodMirror methodMirror) {
  return methodMirror.metadata
      .map((InstanceMirror im) => im.reflectee);
}

Iterable<Object> getPropertyMetadata(MethodMirror methodMirror, TypeMirror typeMirror) {
  return methodMirror.metadata
      .where((InstanceMirror im) => im.type.isSubtypeOf(typeMirror))
      .map((InstanceMirror im) => im.reflectee);
}

MethodMirror getMethodMirrorFromClass(Type klass, String method) {
  return reflectClass(klass).instanceMembers.values
      .firstWhere((MethodMirror mm) => mm.simpleName == MirrorSystem.getSymbol(method),
        orElse: () => null);
}

class Metadata<T> extends Iterable<T> {

  final Iterable<T> _iterable;
  final TypeMirror mirror;

  Metadata._(this._iterable, this.mirror);

  factory Metadata(Iterable<T> iterable, TypeMirror mirror) {
    return new Metadata._(iterable, mirror);
  }

  factory Metadata.fromClass(Type klass) {
    return new Metadata<T>.fromClassMirror(reflectClass(klass));
  }

  factory Metadata.fromClassMirror(ClassMirror classMirror) {
    final TypeMirror mirror = reflectType(T);
    return new Metadata(
      classMirror.metadata
      .where((InstanceMirror im) {
        return im.type.isSubtypeOf(mirror);
      })
      .map((InstanceMirror im) {
        return im.reflectee;
      }),
      mirror
    );
  }

  factory Metadata.fromMethod(Type klass, String method) {
    return new Metadata.fromMethodMirror(
      getMethodMirrorFromClass(klass, method)
    );
  }

  factory Metadata.fromMethodMirror(MethodMirror methodMirror) {
    final TypeMirror mirror = reflectType(T);
    return new Metadata(methodMirror.metadata
        .where((InstanceMirror im) => im.type.isSubtypeOf(mirror))
        .map((InstanceMirror im) => im.reflectee), mirror);
  }

  @override
  Iterator<T> get iterator => _iterable.iterator;
}

@AuthenticationRequired
@AnonymousRequired
@PasswordAuthenticationRequired
class ApplicationController extends Controller {

  @Route(route: r'/')
  @Route(route: r'/index')
  Future index() async {}
}

void main() {
  print(new Metadata<AuthenticationFilter>.fromClass(ApplicationController));
  print(new Metadata<Route>.fromMethod(ApplicationController, 'index'));
}
