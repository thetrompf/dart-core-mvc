part of router;

/// The [Route] interface containing
/// information about a [controller] and [action] pair
/// to be called when a [verb] and [route] match is found by the [Router].
abstract class Route implements Annotation {
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

  /// The request [timeout] in seconds.
  int get timeout;

  const factory Route(
      Pattern route,
      {HttpVerb verb,
      String library,
      String controller,
      String action,
      int timeout}) = _DefaultRoute;

  /// Finds out whether or not the [uri] matches the [route] [Pattern] provided.
  bool match(Uri uri, String verb);
}

/// The default implementation of a [Route].
/// It just acts like a property bag once it is constructed.
class _DefaultRoute implements Route {
  final Pattern route;
  final HttpVerb verb;
  final String library;
  final String controller;
  final String action;
  final int timeout;

  const _DefaultRoute(
      this.route,
      {this.verb: HttpVerb.GET,
      this.library: null,
      this.controller: null,
      this.action: null,
      this.timeout: 30});

  @override
  bool match(Uri uri, String method) {
    if (verb != method) {
      return false;
    }
    RegExp r = new RegExp(r'^' + route.toString() + r'$');
    Iterable<Match> res = r.allMatches(uri.path);
    return res.length > 0;
  }
}
