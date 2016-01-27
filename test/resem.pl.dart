library test.resem.pl;

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
}

class TestApplication extends DefaultApplication {

  TestApplication({Router router, Logger logger, InternetAddress address, int port, Injector injector}) :
    super(
      router: router,
      logger: logger,
      address: address,
      port: port,
      injector: injector
    );

  Future initializeRouter(List<Route> routes) async {
    print('hans');
    routes.add(new Route(
      library: 'test.resem.pl',
      controller: 'TestController',
      action: 'index',
      route: '/',
      verb: HttpVerb.GET
    ));
    print('hans2');
  }
}

void main() {
  group("Simple requests", () {
    Application app = null;
    HttpClient client = null;

    setUp(() async {
      app = new TestApplication(logger: new TtyLogger(group: 'test', level: ERROR_LEVEL), port: 3331);
      client = new HttpClient();
      print('erik');
      await app.start();
      print('erik2');
    });

    test("valid requests returns HttpStatus.OK", () async {
      print('requesting');
      var req = await client.getUrl(Uri.parse('http://localhost:3331'));
      print('requested');
      var res = await req.close();
      print('closed');
      expect(res.statusCode, HttpStatus.OK, reason: 'valid http request to root should return status code 200 (HttpStatus.OK)');
    });

    test("requests to non-existing resource returns HttpStatus.NOT_FOUND", () async {
      var req = await client.getUrl(Uri.parse('http://localhost:3331/non-existing-resources'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.NOT_FOUND, reason: 'requesting non-exsting resources should return status code 404 (HttpStatus.NOT_FOUND)');
    });

    tearDown(() async {
      await app.stop();
      app = null;
      client = null;
    });
  });
}
