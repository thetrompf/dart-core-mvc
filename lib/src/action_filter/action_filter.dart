part of action_filter;

abstract class FilterContext {
  HttpContext get httpContext;
  factory FilterContext({HttpContext httpContext}) = DefaultFilterContext;
}

class DefaultFilterContext implements FilterContext {
  final HttpContext httpContext;
  DefaultFilterContext({this.httpContext});
}

class FilterResult {}
class FilterPassResult implements FilterResult {
  const FilterPassResult();
}

abstract class ActionFilter {
  Future<FilterResult> executeActionFilter(FilterContext context);
}
abstract class AuthenticationFilter {
  Future<FilterResult> executeAuthenticationFilter(FilterContext context);
}
abstract class AuthorizationFilter {
  Future<FilterResult> executeAuthorizationFilter(FilterContext context);
}

const AuthenticationRequired = const DefaultAuthenticationRequired();
class DefaultAuthenticationRequired implements AuthenticationFilter {
  const DefaultAuthenticationRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const PasswordAuthenticationRequired = const DefaultPasswordAuthenticationRequired();
class DefaultPasswordAuthenticationRequired implements AuthenticationFilter {
  const DefaultPasswordAuthenticationRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const ADFSAuthenticationRequired = const DefaultADFSAuthenticationRequired();
class DefaultADFSAuthenticationRequired implements AuthenticationFilter {
  const DefaultADFSAuthenticationRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const TokenAuthenticationRequired = const DefaultTokenAuthenticationRequired();
class DefaultTokenAuthenticationRequired implements AuthenticationFilter {
  const DefaultTokenAuthenticationRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const AnonymousRequired = const DefaultAnonymousRequired();
class DefaultAnonymousRequired implements AuthenticationFilter {
  const DefaultAnonymousRequired();

  @override
  Future<FilterResult> executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const GenericCreatePermissionRequired = const DefaultGenericCreatePermissionRequired();
class DefaultGenericCreatePermissionRequired implements AuthorizationFilter {
  const DefaultGenericCreatePermissionRequired();

  @override
  Future<FilterResult> executeAuthorizationFilter(FilterContext context) async {
    return null;
  }
}
