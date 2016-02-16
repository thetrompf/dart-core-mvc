library authenticated_request_test.integration.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/mvc.dart' show Controller, Model;
import 'dart:async' show Future, Stream;
import 'package:resem.pl/action_result.dart' show ActionResult;
import 'package:resem.pl/resem.pl.dart' show Application, DefaultApplication, HttpVerb, Route;
import 'package:resem.pl/logger.dart' show Logger, TtyLogger, ERROR_LEVEL;
import 'dart:io' show HttpClient, HttpStatus;
import 'package:resem.pl/action_filter.dart' show AuthenticationFilter, FilterContext, FilterResult, FilterPassResult;

const TokenAuth = const TokenAuthenticationRequired();
class TokenAuthenticationRequired implements AuthenticationFilter {

  const TokenAuthenticationRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    var params = context.httpContext.request.requestedUri.queryParameters;
    if(params.containsKey('authnToken') && params['authnToken'] == 'Test') {
      return const FilterPassResult();
    }
    return new FilterResult();
  }
}

const FailAuth = const FailAuthentication();
class FailAuthentication implements AuthenticationFilter {

  const FailAuthentication();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return new FilterResult();
  }
}

const WinAuth = const WinAuthentication();
class WinAuthentication implements AuthenticationFilter {

  const WinAuthentication();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return const FilterPassResult();
  }
}

const WinTokenAuth = const CompositeAuth(const [WinAuth, TokenAuth]);

class TestController extends Controller {

  @Route(route: r'/login', verb: HttpVerb.POST)
  Future<ActionResult> login() async {
    return jsonResult({'success': true});
  }

  @Route(route: r'/my-profile')
  @FailAuth
  Future<ActionResult> myProfile() async {
    return jsonResult({'name': 'Test'});
  }

  @TokenAuth
  @Route(route: r'/token-auth-test')
  Future<ActionResult> tokenTest() async {
    return jsonResult({'success': true});
  }

  @Route(route: r'/multiple-auth')
  @TokenAuth
  @FailAuth
  @WinAuth
  Future<ActionResult> multipleAuth() async {
    return jsonResult({'win': true});
  }

  @Route(route: r'/composite-auth')
  @WinTokenAuth
  Future<ActionResult> compositeAuthFail() async {
    return jsonResult({'fail': true});
  }

}

class CompositeAuth implements AuthenticationFilter {
  final Iterable<AuthenticationFilter> filters;
  const CompositeAuth(this.filters);

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return await filters.fold(const FilterPassResult(), (prev, filter) async {
      if(await prev is! FilterPassResult) {
        return prev;
      }
      return filter.executeAuthenticationFilter(context);
    });
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
      await app.stop(force: true);
      app = null;
      client = null;
    });
  });
}
