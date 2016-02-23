part of action_filter;

/// This is the authentication filter interface.
/// Controller actions annotated with classes that a subtype of this filter
/// will be run by the [Router] before [AuthorizationFilter]s, [ActionFilter]s
/// and more importantly before the controller action will be executed.
///
/// If a single authentication filter passes (not throws) the authentication
/// phase successfully over. All authentication filters must fail in order
/// for the request to stop and opt-out.
///
/// In order require multiple authentication filters to pass use
/// the [CompositeAuthenticationRequired] filter.
abstract class AuthenticationFilter implements Annotation {

  /// This method is called by the [Router] in the authentication
  /// lifecycle phase.
  Future executeAuthenticationFilter(AuthenticationFilterContext context);
}

/// With this [AuthenticationFilter] it is possible to require
/// multiple authentication filters must pass.
///
///   const WinTokenAuth = const CompositeAuthenticationRequired(const [
///     const WinAuth(),
///     const TokenAuth()
///   ])
///
///   class WinController extends Controller {
///
///     @WinTokenAuth
///     @Route(r'/')
///     Future action() async {}
///
///   }
class CompositeAuthenticationRequired implements AuthenticationFilter {

  final Iterable<AuthenticationFilter> filters;
  const CompositeAuthenticationRequired(this.filters);

  @override
  Future executeAuthenticationFilter(AuthenticationFilterContext context) {
    return filters.fold(null, (prev, filter) async {
      await prev;
      return filter.executeAuthenticationFilter(context);
    });
  }
}

/// Use this filter to require that the user's identity is known
/// to the framework regardless of authentication method.
const DefaultAuthenticationRequired AuthenticationRequired = const DefaultAuthenticationRequired();

/// Implementation of [AuthenticationRequired].
class DefaultAuthenticationRequired implements AuthenticationFilter {
  const DefaultAuthenticationRequired();

  @override
  Future executeAuthenticationFilter(AuthenticationFilterContext context) async {
    if(!await context.authnManager.isAuthenticated(context.httpContext.request.session)) {
      throw new AuthenticationFilterException("The user is not authenticated");
    }
  }
}

/// Use this filter to require that user's identity has been determined
/// by the default password authentication mechanism.
const DefaultPasswordAuthenticationRequired PasswordAuthenticationRequired = const DefaultPasswordAuthenticationRequired();

/// Implementation of [PasswordAuthenticationRequired].
class DefaultPasswordAuthenticationRequired implements AuthenticationFilter {
  const DefaultPasswordAuthenticationRequired();

  @override
  Future executeAuthenticationFilter(AuthenticationFilterContext context) async {}
}

/// Use this filter to require the user to be anonymous (not authenticated).
const DefaultAnonymousRequired AnonymousRequired = const DefaultAnonymousRequired();

/// Implementation of [AnonymousRequired].
class DefaultAnonymousRequired implements AuthenticationFilter {
  const DefaultAnonymousRequired();

  @override
  Future executeAuthenticationFilter(AuthenticationFilterContext context) async {
    if(await context.authnManager.isAuthenticated(context.httpContext.request.session)) {
      throw new AuthenticationFilterException("The user must not be authenticated");
    }
  }
}
