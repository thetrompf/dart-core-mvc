part of action_filter;

/// The base action filter exception.
/// all action filters will throw a subtype of this exception.
abstract class ActionFilterException implements Exception {}

/// When an authentication filter fails it should throw this exception type
/// the [Router] will then catch the exception and stop the request
/// and notify the user with an UNAUTHORIZED response.
class AuthenticationFilterException implements ActionFilterException {

  final String message;
  const AuthenticationFilterException(this.message);

  String toString() => "[AuthenticationFilterException]: $message";

}

/// WHen an authorization filter fails it must throw an exception of this
/// type, the [Router] will then catch the exception and stop the request
/// and notify the user with an UNAUTHORIZED response.
class AuthorizationFilterException implements ActionFilterException {

  final String message;
  const AuthorizationFilterException(this.message);

  String toString() => "[AuthorizationFilterException]: $message";

}
