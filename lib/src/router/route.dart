part of router;

/// The [Route] interface containing
/// information about a [controller] and [action] pair
/// to be called when a [verb] and [route] match is found by the [Router].
abstract class Route {
  /// The [library] where the [controller] lives.
  String get library;

  /// The [controller] container the [action]
  String get controller;

  /// The [action] to be called when matching [verb] and [route] is found.
  String get action;

  /// The [route] [Pattern] that has to match.
  Pattern get route;

  /// The [verb] to be called.
  HttpVerb get verb;

  factory Route(
      {HttpVerb verb,
      Pattern route,
      String library,
      String controller,
      String action}) = _DefaultRoute;

  /// Finds out whether or not the [uri] matches the [route] [Pattern] provided.
  bool match(Uri uri);
}

/// The default implementation of a [Route].
/// It just acts like a property bag once it is constructed.
class _DefaultRoute implements Route {
  final String library;
  final String controller;
  final String action;
  final Pattern route;
  final HttpVerb verb;

  const _DefaultRoute(
      {this.verb: HttpVerb.GET,
      this.route,
      this.library: null,
      this.controller: null,
      this.action: null});

  @override
  bool match(Uri uri) => route.allMatches('/^' + uri.path + '\$/').length > 0;
}
