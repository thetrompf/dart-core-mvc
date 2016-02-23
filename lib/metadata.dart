/// The [metadata] library.
library metadata;

import 'dart:mirrors';

/// The [Annotation] tag interface.
abstract class Annotation {}

/// Mirror of the [Annotation] tag interface.
final TypeMirror _annotationMirror = reflectType(Annotation);

/// Get a method mirror from a [Type] and [String].
MethodMirror _getMethodMirrorFromClass(Type klass, String method) {
  return reflectClass(klass).instanceMembers.values
    .firstWhere(
      (MethodMirror mm) => mm.simpleName == MirrorSystem.getSymbol(method),
      orElse: () => null
    );
}

/// Get all class metadata of type [Annotation] annotated on [classMirror].
Iterable<Annotation> _getAllClassMetadata(ClassMirror classMirror) {
  return classMirror.metadata
    .where((InstanceMirror im) => im.type.isSubtypeOf(_annotationMirror))
    .map((InstanceMirror im) => im.reflectee);
}

/// Get all method metadata of type [Annotation] annotated on [methodMirror].
Iterable<Annotation> _getAllMethodMetadata(MethodMirror methodMirror) {
  return methodMirror.metadata
    .where((InstanceMirror im) => im.type.isSubtypeOf(_annotationMirror))
    .map((InstanceMirror im) => im.reflectee);
}

/// Metadata wrapper class for [Annotation] instances annotated
/// on classes, methods or properties.
class Metadata<T extends Annotation> extends Iterable<T> {

  final Iterable<T> _iterable;

  Metadata._(this._iterable);

  /// Get all [Annotation] instances annotated on [klass].
  factory Metadata.fromClass(Type klass) {
    return new Metadata<T>.fromClassMirror(reflectClass(klass));
  }

  /// Get all [Annotation] instances annotated on [classMirror].
  factory Metadata.fromClassMirror(ClassMirror classMirror) {
    return new Metadata._(
      _getAllClassMetadata(classMirror)
      // The T == dynamic test is used for testing when no generic type <T> is given
      // It means just return all of type [Annotation].
      .where((Annotation a) => a.runtimeType == T || T == dynamic)
    );
  }

  /// Get all [Annotation] instances annotated on [klass].[method].
  factory Metadata.fromMethod(Type klass, String method) {
    return new Metadata<T>.fromMethodMirror(
      _getMethodMirrorFromClass(klass, method)
    );
  }

  /// Get all [Annotation] instances annotated on [methodMirror].
  factory Metadata.fromMethodMirror(MethodMirror methodMirror) {
    return new Metadata._(
      _getAllMethodMetadata(methodMirror)
      // The T == dynamic test is used for testing when no generic type <T> is given
      // It means just return all of type [Annotation].
      .where((Annotation a) => a.runtimeType == T || T == dynamic)
    );
  }

  @override
  Iterator<T> get iterator => _iterable.iterator;
}
