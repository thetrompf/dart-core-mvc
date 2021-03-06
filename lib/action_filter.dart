/// This library contains the base classes / interfaces
/// utilized by the [router] for filtering incoming request in an early
/// stage of the request lifecycle, usually used for disallowing
/// request where the user is not authenticated or not authorized to make
/// the request.
///
///     import 'package:core_mvc/mvc.dart'
///       show Controller;
///     import 'package:core_mvc/action_filter.dart'
///       show AuthenticationFilter, AuthenticationFilterException, FilterContext
///
///     cont TokenAuth = const TokenAuthFilter();
///     class TokenAuthFilter implements AuthenticationFilter {
///
///       const TokenAuthFilter();
///
///       Future executeAuthenticationFilter(FilterContext context) async {
///         final params = context.httpContext.request.requestedUri.queryParams;
///         if(!params.containsKey('authnToken') || params['authnToken'] != 'example') {
///           throw new AuthenticationFilterException("Invalid token");
///         }
///       }
///     }
///
///     class TestController extends Controller {
///
///       @TokenAuth
///       @Route(route: r'/token-example')
///       Future action() async {}
///
///     }
///
///
library action_filter;

import 'dart:async' show Future;
import 'package:core_mvc/http.dart' show HttpContext;
import 'package:core_mvc/authentication.dart' show AuthenticationManager;
import 'package:core_mvc/metadata.dart' show Annotation;

part 'src/action_filter/action_filter.dart';
part 'src/action_filter/authentication_filter.dart';
part 'src/action_filter/authorization_filter.dart';
part 'src/action_filter/filter_context.dart';
part 'src/action_filter/exceptions.dart';
