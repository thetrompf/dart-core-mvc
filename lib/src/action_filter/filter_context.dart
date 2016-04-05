part of action_filter;

/// The interface for an action filter context.
/// An action filter context is provided to every
/// [ActionFilter] annotated on controller actions
/// in the action filter lifecycle phase of the application.
abstract class FilterContext {

  /// The inner context to access the request and response object through.
  HttpContext get httpContext;

  factory FilterContext({HttpContext httpContext}) = DefaultFilterContext;
}

/// Base interface for authentication action filter context.
/// An authentication filter context is provided to every
/// [AuthenticationFilter] annotation on controller actions
/// in the authentication lifecycle phase of the application.
abstract class AuthenticationFilterContext extends FilterContext {

  /// HTTP context of the current request.
  HttpContext get httpContext;

  /// The authentication manager configured in this application.
  AuthenticationManager get authnManager;

  factory AuthenticationFilterContext({HttpContext httpContext, AuthenticationManager authnManager})
    = DefaultAuthenticationFilterContext;
}

/// Default implementation of the [FilterContext] interface.
class DefaultFilterContext implements FilterContext {

  final HttpContext httpContext;
  DefaultFilterContext({this.httpContext});
}

/// Default implementation of the [AuthenticationFilterContext] interface.
class DefaultAuthenticationFilterContext implements AuthenticationFilterContext {
  final HttpContext httpContext;
  final AuthenticationManager authnManager;

  DefaultAuthenticationFilterContext({this.httpContext, this.authnManager});
}
