library ioc_binding_test.unit.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/ioc.dart'
    show bind, abstractMapCopy, concreteMapCopy, Binding;

class TestType {}

class TestAbstractType {}

void main() {
  group('Unit', () {
    group('IOC', () {
      group('bind', () {
        test('A Binding object is returning when binding a Type', () {
          var binding = bind(TestType);
          expect(binding, new isInstanceOf<Binding>());
        });

        test('Creating bindings makes the binding maps grow', () {
          bind(TestType);
          expect(abstractMapCopy.keys, hasLength(0));
          expect(concreteMapCopy.keys, hasLength(0));

          var abstractBinding = bind(TestType).to(TestAbstractType);
          expect(abstractMapCopy, containsPair(TestType, abstractBinding));

          var concreteBinding = bind(TestType).to(new TestAbstractType());
          expect(concreteMapCopy, containsPair(TestType, concreteBinding));
        });
      });
    });
  });
}
