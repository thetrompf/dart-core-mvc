part of action_filter;

abstract class ActionFilterException implements Exception {}

class AuthenticationFilterException implements ActionFilterException {

  final String message;
  const AuthenticationFilterException(this.message);

  String toString() => "[AuthenticationFilterException]: $message";

}

class AuthorizationFilterException implements ActionFilterException {

  final String message;
  const AuthorizationFilterException(this.message);

  String toString() => "[AuthorizationFilterException]: $message";

}
