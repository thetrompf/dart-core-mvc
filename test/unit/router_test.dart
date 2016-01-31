library router_test.unit.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/router.dart';
import 'package:resem.pl/http.dart' show HttpVerb;

void main() {
  group("Unit", () {
    group("Router", () {
      var router;

      setUp(() {
        var routes = <Route>[
          const Route(
            verb: HttpVerb.GET,
            route: r'/',
            library: 'router_test.unit.resem.pl',
            controller: 'TestController',
            action: 'test'
          ),
          const Route(
            verb: HttpVerb.POST,
            route: r'/matching-uri-non-matching-verb',
            library: 'TestController',
            action: 'test'
          )
        ];
        router = new Router(routes);
      });

      test('Matching a route returns the Route object', () {
        Route route = router.route(Uri.parse('https://localhost:3331/'));
        expect(route, new isInstanceOf<Route>());
      });

      test('Non-matching Uri shouldn\'t route', () {
        Route route = router.route(Uri.parse('https://localhost:3331/non-matching-route'));
        expect(route, isNull, reason: 'A non matching Uri should return null');
      });

      test('Matching Uri with non-matching verb shouldn\'t route', () {
        Route route = router.route(Uri.parse('https://localhost:3331/matching-uri-non-matching-verb'));
        expect(route, isNull, reason: 'Non matching Uri and verb should return null');
      });

      tearDown(() {
        router = null;
      });
    });
  });
}
