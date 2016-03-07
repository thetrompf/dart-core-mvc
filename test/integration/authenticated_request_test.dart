library authenticated_request_test.integration.resem.pl;

import 'dart:async'
    show Future, Stream;
import 'dart:io'
    show HttpClient, HttpStatus;

import 'package:test/test.dart';

import 'package:resem.pl/mvc.dart'
    show Controller, Model;
import 'package:resem.pl/action_result.dart'
    show ActionResult;
import 'package:resem.pl/resem.pl.dart'
    show Application, DefaultApplication, HttpVerb, Route;
import 'package:resem.pl/logger.dart'
    show Logger, TtyLogger, ERROR_LEVEL;
import 'package:resem.pl/action_filter.dart'
    show AuthenticationFilter, FilterContext,
    AuthenticationFilterException, CompositeAuthenticationRequired;

const TokenAuth = const TokenAuthenticationRequired();
class TokenAuthenticationRequired implements AuthenticationFilter {

  const TokenAuthenticationRequired();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {
    var params = context.httpContext.request.requestedUri.queryParameters;
    if(!params.containsKey('authnToken') || params['authnToken'] != 'Test') {
      throw new AuthenticationFilterException('Invalid token');
    }
  }
}

const FailAuth = const FailAuthentication();
class FailAuthentication implements AuthenticationFilter {

  const FailAuthentication();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {
    throw new AuthenticationFilterException('Fail!');
  }
}

const WinAuth = const WinAuthentication();
class WinAuthentication implements AuthenticationFilter {

  const WinAuthentication();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {}
}

const WinTokenAuth = const CompositeAuthenticationRequired(const [WinAuth, TokenAuth]);

class TestController extends Controller {

  @Route(r'/login', verb: HttpVerb.POST)
  Future<ActionResult> login() async {
    return jsonResult({'success': true});
  }

  @FailAuth
  @Route(r'/my-profile')
  Future<ActionResult> myProfile() async {
    return jsonResult({'name': 'Test'});
  }

  @TokenAuth
  @Route(r'/token-auth-test')
  Future<ActionResult> tokenTest() async {
    return jsonResult({'success': true});
  }

  @TokenAuth @FailAuth @WinAuth
  @Route(r'/multiple-auth')
  Future<ActionResult> multipleAuth() async {
    return jsonResult({'win': true});
  }

  @WinTokenAuth
  @Route(r'/composite-auth')
  Future<ActionResult> compositeAuthFail() async {
    return jsonResult({'fail': true});
  }

}

class TestApplication extends DefaultApplication {
  TestApplication({Logger logger, int port}) : super(logger: logger, port: port);
}

void main() {
  group('Request actions with authentication filters', () {
    Application app;
    HttpClient client;
    setUp(() async {
      app = new TestApplication(
          logger: new TtyLogger(group: 'test', level: ERROR_LEVEL),
          port: 3335);
      client = new HttpClient();
      await app.start();
    });

    test("where conditions aren't met should "
        "return HttpStatus.UNAUTHORIZED (401)", () async {
      var req = await client.getUrl(
          Uri.parse(
            r'http://localhost:3335/my-profile'
          )
      );
      var res = await req.close();
      expect(res.statusCode, HttpStatus.UNAUTHORIZED,
          reason:
          'Unauthorized requests should '
              'return status code 401 (HttpStatus.UNAUTHORIZED)');
    });

    test("where conditions are met should "
        "return HttpStatus.OK (200)", () async {
      var req = await client.getUrl(
          Uri.parse(
            r'http://localhost:3335/token-auth-test?authnToken=Test'
          )
      );
      var res = await req.close();
      expect(res.statusCode, HttpStatus.OK,
          reason: 'When authentication filter criterias are met the request '
              'should return status code 200 (HttpStatus.OK)');
    });

    test("if one passes the request should return HttpStatus.OK (200)", () async {
      var req = await client.getUrl(
          Uri.parse(
              r'http://localhost:3335/multiple-auth'
          )
      );
      var res = await req.close();
      expect(res.statusCode, HttpStatus.OK,
          reason: 'Request should return code 200 (HttpStatus.OK) '
              'because WinAuth filter passes');
    });

    test("where a filter inside a composite filter doesn't "
        "should return 401 (HttpStatus.UNAUTHORIZED)", () async {
      var req = await client.getUrl(
          Uri.parse(
              r'http://localhost:3335/composite-auth'
          )
      );
      var res = await req.close();
      expect(res.statusCode, HttpStatus.UNAUTHORIZED,
          reason: "TokenAuth does not pass so the request "
              "should return 401 (HttpStatus.UNAUTHORIZED)");
    });

    test("where all filters inside a composite filter passes "
        "should return 200 (HttpStatus.OK)", () async {
      var req = await client.getUrl(
          Uri.parse(
              r'http://localhost:3335/composite-auth?authnToken=Test'
          )
      );
      var res = await req.close();

      expect(res.statusCode, HttpStatus.OK,
          reason: 'All filters pass thus the request '
              'should return 200 (HttpStatus.OK)');
    });

    tearDown(() async {
      await app.stop();
      app = null;
      client = null;
    });
  });
}
