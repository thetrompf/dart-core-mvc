library router_test.unit.resem.pl;

import 'dart:io' show HttpRequest;

import 'package:mockito/mockito.dart';
import 'package:resem.pl/http.dart' show HttpVerb;
import 'package:resem.pl/router.dart';
import 'package:test/test.dart';

@TestOn('vm')
class MockHttpRequest extends Mock implements HttpRequest {}

void main() {
  group("Unit", () {
    group("Router", () {
      var router;

      setUp(() {
        const routes = const <Route>[
          const Route(
              r'/',
              verb: HttpVerb.GET,
              library: 'router_test.unit.resem.pl',
              controller: 'TestController',
              action: 'test'),
          const Route(
              r'/matching-uri-non-matching-verb',
              verb: HttpVerb.POST,
              library: 'TestController',
              action: 'test')
        ];
        router = new Router(routes);
      });

      test('Matching a route returns the Route object', () {
        var req = new MockHttpRequest();
        when(req.uri).thenReturn(Uri.parse('https://localhost:3331/'));
        when(req.method).thenReturn('GET');

        Route route = router.route(req);
        expect(route, new isInstanceOf<Route>());
      });

      test('Non-matching Uri shouldn\'t route', () {
        var req = new MockHttpRequest();
        when(req.uri)
            .thenReturn(Uri.parse('https://localhost:3331/non-matching-route'));
        when(req.method).thenReturn('GET');

        Route route = router.route(req);
        expect(route, isNull, reason: 'A non matching Uri should return null');
      });

      test('Matching Uri with non-matching verb shouldn\'t route', () {
        var req = new MockHttpRequest();
        when(req.uri).thenReturn(
            Uri.parse('https://localhost:3331/matching-uri-non-matching-verb'));
        when(req.method).thenReturn('GET');

        Route route = router.route(req);
        expect(route, isNull,
            reason: 'Non matching Uri and verb should return null');
      });

      tearDown(() {
        router = null;
      });
    });
  });
}
