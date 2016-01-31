library application_routing_test.system.resem.pl;

import 'dart:async' show Future, Timer;
import 'dart:io' show HttpClient, HttpStatus, InternetAddress;

import 'package:resem.pl/action_result.dart' show ActionResult, StringResult;
import 'package:resem.pl/application.dart' show Application, DefaultApplication;
import 'package:resem.pl/http.dart' show HttpVerb;
import 'package:resem.pl/ioc.dart' show Injector;
import 'package:resem.pl/logger.dart'
    show Logger, TtyLogger, SILENT_LEVEL, ERROR_LEVEL;
import 'package:resem.pl/router.dart' show Route, Router;
import 'package:resem.pl/mvc.dart' show Controller;
import 'package:test/test.dart';
// import 'package:mockito/mockito.dart';

@TestOn("vm")
class TestController extends Controller {
  Future<ActionResult> index() async => stringResult('test');

  Future<ActionResult> throwing() async => throw "Must throw";

  Future<ActionResult> timeout() async {
    return new Future.delayed(
        const Duration(seconds: 5), () => stringResult('timeout'));
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
    routes.add(const Route(
        library: 'application_routing_test.system.resem.pl',
        controller: 'TestController',
        action: 'index',
        route: '/',
        verb: HttpVerb.GET));
    routes.add(const Route(
        library: 'application_routing_test.system.resem.pl',
        controller: 'TestController',
        action: 'throwing',
        route: '/throwing-resources',
        verb: HttpVerb.GET));
    routes.add(const Route(
        library: 'application_routing_test.system.resem.pl',
        controller: 'TestController',
        action: 'timeout',
        route: '/timeout',
        verb: HttpVerb.GET,
        timeout: 1));
  }
}

void main() {
  group("System", () {
    group("Status codes", () {
      Application app = null;
      HttpClient client = null;

      setUp(() async {
        app = new TestApplication(
            logger: new TtyLogger(group: 'test', level: ERROR_LEVEL),
            port: 3331);
        client = new HttpClient();
        await app.start();
      });

      test("A successful request returns HttpStatus.OK", () async {
        var req = await client.getUrl(Uri.parse('http://localhost:3331'));
        var res = await req.close();
        expect(res.statusCode, HttpStatus.OK,
            reason:
                'valid http request to root should return status code 200 (HttpStatus.OK)');
      });

      test("Requesting a non-existing resource returns HttpStatus.NOT_FOUND",
          () async {
        var req = await client
            .getUrl(Uri.parse('http://localhost:3331/non-existing-resources'));
        var res = await req.close();
        expect(res.statusCode, HttpStatus.NOT_FOUND,
            reason:
                'requesting non-exsting resources should return status code 404 (HttpStatus.NOT_FOUND)');
      });

      test(
          "Requesting a resource with an uncaught throw returns HttpStatus.INTERNAL_SERVER_ERROR",
          () async {
        var req = await client
            .getUrl(Uri.parse('http://localhost:3331/throwing-resources'));
        var res = await req.close();
        expect(res.statusCode, HttpStatus.INTERNAL_SERVER_ERROR,
            reason:
                'requesting throwing resources should return status code 500 (HttpStatus.INTERNAL_SERVER_ERROR)');
      });

      test(
          "Requesting a resource that times out returns HttpStatus.GATEWAY_TIMEOUT",
          () async {
        var req =
            await client.getUrl(Uri.parse('http://localhost:3331/timeout'));
        var res = await req.close();
        expect(res.statusCode, HttpStatus.GATEWAY_TIMEOUT,
            reason:
                'requesting a route that runs over the timeout threshold should return status code 504 (HttpStatus.GATEWAY_TIMEOUT)');
      });

      tearDown(() async {
        await app.stop();
        app = null;
        client = null;
      });
    });
  });
}
