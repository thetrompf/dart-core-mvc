library metadata_test.unit.core_mvc;

import 'package:test/test.dart';
import 'package:core_mvc/metadata.dart';

class ClassAnnotation implements Annotation {
  const ClassAnnotation();
}

const ClassAnnotation ClassMetadata = const ClassAnnotation();

class NotAnnotation {
  const NotAnnotation();
}

const NotAnnotation NotMetadata = const NotAnnotation();

class MethodAnnotation implements Annotation {
  const MethodAnnotation();
}

const MethodAnnotation MethodMetadata = const MethodAnnotation();

class PropertyAnnotation implements Annotation {
  const PropertyAnnotation();
}

const PropertyAnnotation PropertyMetadata = const PropertyAnnotation();

@ClassMetadata
@NotMetadata
class TestClass {

  @PropertyMetadata
  @NotMetadata
  String get prop => 'Property';

  @MethodMetadata
  @NotMetadata
  void index() {}

}

void main() {
  test('Annotations on classes collected by the Metadata wrapper', () {
    Iterable<ClassAnnotation> classAnnotations = new Metadata<ClassAnnotation>.fromClass(TestClass);
    Iterable<Annotation> allAnnotations = new Metadata.fromClass(TestClass);
    expect(classAnnotations, hasLength(1));
    expect(allAnnotations, hasLength(1));
  });

  test('Annotations on methods collected by the Metadata wrapper', () {
    Iterable<MethodAnnotation> methodAnnotations = new Metadata<MethodAnnotation>.fromMethod(TestClass, 'index');
    Iterable<Annotation> allMethodAnnotations = new Metadata.fromMethod(TestClass, 'index');
    expect(methodAnnotations, hasLength(1));
    expect(allMethodAnnotations, hasLength(1));
  });

  test('Annotations on properties collected by The Metadata wrapper', () {
    Iterable<PropertyAnnotation> propertyAnnotations = new Metadata<PropertyAnnotation>.fromMethod(TestClass, 'prop');
    Iterable<PropertyAnnotation> allPropertyAnnotations = new Metadata.fromMethod(TestClass, 'prop');
    expect(propertyAnnotations, hasLength(1));
    expect(allPropertyAnnotations, hasLength(1));
  });
}
