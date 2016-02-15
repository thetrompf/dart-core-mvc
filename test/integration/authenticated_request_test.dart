library authenticated_request_test.integration.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/mvc.dart' show Controller, Model;
import 'dart:async' show Future;
import 'package:resem.pl/action_result.dart' show ActionResult;
import 'package:resem.pl/resem.pl.dart' show Application, DefaultApplication, HttpVerb, Route;
import 'package:resem.pl/logger.dart' show Logger, TtyLogger, ERROR_LEVEL;
import 'package:resem.pl/action_filter.dart' show AuthenticationRequired;
import 'dart:io';

class TestController extends Controller {

  @Route(route: r'/login', verb: HttpVerb.POST)
  Future<ActionResult> login() async {
    return jsonResult({'success': true});
  }

  @Route(route: r'/my-profile')
  @AuthenticationRequired
  Future<ActionResult> myProfile() async {
    return jsonResult({'name': 'Test'});
  }
}

class TestApplication extends DefaultApplication {
  TestApplication({Logger logger, int port}) : super(logger: logger, port: port);
}

void main() {
  Application app;
  HttpClient client;
  setUp(() async {
    app = new TestApplication(
        logger: new TtyLogger(group: 'test', level: ERROR_LEVEL),
        port: 3335);
    client = new HttpClient();
    await app.start();
  });

  test("Request against actions where authentication filter request aren't met should return HttpStatus.UNAUTHORIZED (401)", () async {
    var req = await client.getUrl(Uri.parse('http://localhost:3335/my-profile'));
    var res = await req.close();
    expect(res.statusCode, HttpStatus.UNAUTHORIZED,
        reason:
        'Unauthorized requests should return status code 401 (HttpStatus.UNAUTHORIZED)');
  });

  tearDown(() async {
    await app.stop(force: true);
    app = null;
    client = null;
  });
}
