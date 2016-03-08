library ioc_binding_test.unit.core_mvc;

import 'package:core_mvc/ioc.dart'
    show
        Binding,
        CyclicDependencyException,
        IncompatibleBindingException,
        abstractMapCopy,
        bind,
        concreteMapCopy;
import 'package:test/test.dart';

class TestType {}

class TestAbstractType implements TestType {}

class TestIncompatibleType {}

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

        test('Bindings causing circular dependencies throws', () {
          var binding = bind(TestType);
          expect(() => binding.to(TestType),
              throwsA(new isInstanceOf<CyclicDependencyException>()));
        });

        test('Binding so throw on mismatching abstract binding types', () {
          var binding = bind(TestType);
          expect(() => binding.to(TestIncompatibleType),
              throwsA(new isInstanceOf<IncompatibleBindingException>()));
        });
      });
    });
  });
}
