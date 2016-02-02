library enum_test.unit.resem.pl;

import 'dart:mirrors' show reflectClass;

import 'package:resem.pl/type.dart' show Enum;
import 'package:test/test.dart';

var testMirror = reflectClass(TestEnum);

class TestEnum extends Enum<String> {
  static const VALUE1 = const TestEnum('VALUE1');

  const TestEnum(String value) : super(value);

  factory TestEnum.fromString(String value) =>
      new Enum.fromString(value, testMirror);

  String toString() => super.enumToString(testMirror);
}

void main() {
  group('Unit', () {
    group('Type', () {
      group('Enum', () {
        test('Different enum instances of same value are equal', () {
          expect(TestEnum.VALUE1, new TestEnum.fromString('VALUE1'));
        });
        test("Creating enum instances from string that doesn't exists", () {
          expect(() => new TestEnum.fromString('NON-EXISTING'),
              throwsUnsupportedError);
        });

        test('enumToString returns predictable representation of the Enum', () {
          expect(TestEnum.VALUE1.toString(), equals('TestEnum.VALUE1'));
        });
      });
    });
  });
}
