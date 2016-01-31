library json_action_result_test.unit.resem.pl;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:resem.pl/action_result.dart' show JsonResult, ResultContext;
import 'package:resem.pl/http.dart' show HttpContext;
import 'dart:io' show HttpHeaders, HttpResponse;

@TestOn('vm')

class MockHttpResponse extends Mock implements HttpResponse {
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpHeaders extends Mock implements HttpHeaders {
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpContext extends Mock implements HttpContext {
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockResultContext extends Mock implements ResultContext {
  noSuchMethod(i) => super.noSuchMethod(i);
}

void main() {
  group('JsonActionResult', () {
    test('executeAction writes data to response', () async {
      var result = new JsonResult(null);

      var response = new MockHttpResponse();
      var headers = new MockHttpHeaders();
      when(response.headers).thenReturn(headers);
      expect(response.headers, new isInstanceOf<HttpHeaders>());
      expect(response.headers, same(headers));

      var resultContext = new MockResultContext();
      when(resultContext.response).thenReturn(response);
      expect(resultContext.response, same(response));

      await result.executeResult(resultContext);
      verify(response.write(captureAny));
      verify(response.close());
    });
  });
}
