library application_routing_test.system.resem.pl;

import 'package:resem.pl/resem.pl.dart';
import 'package:resem.pl/logger.dart' show SILENT_LEVEL, ERROR_LEVEL;
import 'package:test/test.dart';
// import 'package:mockito/mockito.dart';
import 'dart:io';
import 'dart:async' show Future;
import 'package:resem.pl/http.dart';
import 'package:resem.pl/ioc.dart';
import 'package:resem.pl/application.dart';

@TestOn("vm")
class TestController extends Controller {
  Future index() async {
    return 'test';
  }

  Future throwing() async {
    throw "Must throw";
  }
}

class TestApplication extends DefaultApplication {
  TestApplication(
      {Router router,
      Logger logger,
      InternetAddress address,
      int port,
      Injector injector})
      : super(
            router: router,
            logger: logger,
            address: address,
            port: port,
            injector: injector);

  Future initializeRouter(List<Route> routes) async {
    routes.add(new Route(
        library: 'application_routing_test.system.resem.pl',
        controller: 'TestController',
        action: 'index',
        route: '/',
        verb: HttpVerb.GET));
    routes.add(new Route(
        library: 'application_routing_test.system.resem.pl',
        controller: 'TestController',
        action: 'throwing',
        route: '/throwing-resources',
        verb: HttpVerb.GET));
  }
}

void main() {
  group("Simple requests", () {
    Application app = null;
    HttpClient client = null;

    setUp(() async {
      app = new TestApplication(
          logger: new TtyLogger(group: 'test', level: ERROR_LEVEL), port: 3331);
      client = new HttpClient();
      await app.start();
    });

    test("that are successful returns HttpStatus.OK", () async {
      var req = await client.getUrl(Uri.parse('http://localhost:3331'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.OK,
          reason:
              'valid http request to root should return status code 200 (HttpStatus.OK)');
    });

    test("that hits non-existing resource returns HttpStatus.NOT_FOUND",
        () async {
      var req = await client
          .getUrl(Uri.parse('http://localhost:3331/non-existing-resources'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.NOT_FOUND,
          reason:
              'requesting non-exsting resources should return status code 404 (HttpStatus.NOT_FOUND)');
    });

    test("that hits throwing resource returns HttpStatue.INTERNAL_SERVER_ERROR",
        () async {
      var req = await client
          .getUrl(Uri.parse('http://localhost:3331/throwing-resources'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.INTERNAL_SERVER_ERROR,
          reason:
              'requesting throwing resources should return status code 500 (HttpStatus.INTERNAL_SERVER_ERROR)');
    });

    tearDown(() async {
      await app.stop();
      app = null;
      client = null;
    });
  });
}
