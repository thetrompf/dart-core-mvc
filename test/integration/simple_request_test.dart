library simple_request_test.integration.core_mvc;

import 'dart:async' show Future, Timer;
import 'dart:io' show HttpClient, HttpStatus, InternetAddress;

import 'package:core_mvc/action_result.dart' show ActionResult, StringResult;
import 'package:core_mvc/application.dart' show Application, DefaultApplication;
import 'package:core_mvc/http.dart' show HttpVerb;
import 'package:core_mvc/ioc.dart' show Injector;
import 'package:core_mvc/logger.dart'
    show Logger, TtyLogger, SILENT_LEVEL, ERROR_LEVEL;
import 'package:core_mvc/mvc.dart' show Controller;
import 'package:core_mvc/router.dart' show Route, Router;
import 'package:test/test.dart';

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
        r'/',
        library: 'simple_request_test.integration.core_mvc',
        controller: 'TestController',
        action: 'index',
        verb: HttpVerb.GET));
    routes.add(const Route(
        r'/throwing-resources',
        library: 'simple_request_test.integration.core_mvc',
        controller: 'TestController',
        action: 'throwing',
        verb: HttpVerb.GET));
    routes.add(const Route(
        r'/timeout',
        library: 'simple_request_test.integration.core_mvc',
        controller: 'TestController',
        action: 'timeout',
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
