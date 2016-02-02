library json_action_result_test.unit.resem.pl;

import 'dart:convert' show JsonUnsupportedObjectError;
import 'dart:io' show HttpHeaders, HttpResponse;

import 'package:mockito/mockito.dart';
import 'package:resem.pl/action_result.dart' show JsonResult, ResultContext;
import 'package:resem.pl/http.dart' show HttpContext;
import 'package:test/test.dart';

@TestOn('vm')
class MockHttpResponse extends Mock implements HttpResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class MockHttpContext extends Mock implements HttpContext {}

class MockResultContext extends Mock implements ResultContext {}

class Person {
  final int id;
  final String name;
  final DateTime birthdate;

  Person({this.id, this.name, this.birthdate});
}

void main() {
  group('Unit', () {
    group('JsonActionResult', () {
      var response;
      var headers;
      var resultContext;

      setUp(() {
        response = new MockHttpResponse();
        headers = new MockHttpHeaders();
        when(response.headers).thenReturn(headers);
        expect(response.headers, new isInstanceOf<HttpHeaders>());
        expect(response.headers, same(headers));

        resultContext = new MockResultContext();
        when(resultContext.response).thenReturn(response);
        expect(resultContext.response, same(response));
      });

      test('executeAction writes data to response', () async {
        var result = new JsonResult(null);

        await result.executeResult(resultContext);
        verify(response.write(captureAny));
        verify(response.close());
      });

      test(
          'executeAction throws when non serializable data is written to response',
          () async {
        var person = new Person(
            id: 10,
            name: 'Brian K. Christensen',
            birthdate: new DateTime.now());

        var result = new JsonResult(person);
        expect(result.executeResult(resultContext),
            throwsA(new isInstanceOf<JsonUnsupportedObjectError>()),
            reason:
                'JsonResult should throw conversion error when encoding non serializable objects');
      });

      tearDown(() {
        response = null;
        headers = null;
        resultContext = null;
      });
    });
  });
}
