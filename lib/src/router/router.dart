part of router;

/// The [Router] interface defines the action
/// need to function as a [Router].
///
/// The only thing need is that you can go through the [routes] defined.
/// and can start the [route] mechanism.
abstract class Router {
  /// The [routes] defined in the [Application]
  List<Route> get routes;

  factory Router(List<Route> routes) = DefaultRouter;

  /// Find a route that matches the [uri]
  /// and start the routing mechanism.
  Route route(HttpRequest request);

  /// Process the route and fire up the controller, and execute [Controller.executeAction].
  Future processRoute(Route route, HttpContext context, Injector injector);
}

/// The [DefaultRouter] implementation,
/// it can be extended or customized as one see fit,
/// ot simply just implement the [Router] interface
/// for gaining full control over the routing behavior.
class DefaultRouter implements Router {
  final List<Route> routes;

  DefaultRouter(List<Route> this.routes);

  Route route(HttpRequest req) {
    for (final Route route in routes) {
      if (route.match(req.uri, req.method)) {
        return route;
      }
    }
    return null;
  }

  Future processRoute(Route route, HttpContext context, Injector injector) async {
    final ms = currentMirrorSystem();
    final LibraryMirror library =
        ms.findLibrary(MirrorSystem.getSymbol(route.library));

    final Symbol controllerSymbol =
        MirrorSystem.getSymbol(route.controller, library);

    final controllerMirror =
        library.declarations[controllerSymbol] as ClassMirror;
    final actionMirror =
        controllerMirror.instanceMembers[MirrorSystem.getSymbol(route.action)];

    if(!await _processAllFilters(context, actionMirror)) {
      return;
    }

    final Type controllerType = controllerMirror.reflectedType;
    final Controller controller = injector.getType(controllerType);

    await controller.executeAction(route, context);
  }
}

Future<bool> _processAllFilters(HttpContext context, MethodMirror actionMirror) async {
  final filterContext = new FilterContext(httpContext: context);

  final authenticationFilters = _getAuthenticationFilters(actionMirror);
  if (authenticationFilters.length > 0) {
    var futures = authenticationFilters
        .map((f) => f.executeAuthenticationFilter(filterContext));

    if (!await _processFilters(futures, context)) {
      return false;
    }
  }

  final authorizationFilters = _getAuthorizationFilters(actionMirror);
  if (authorizationFilters.length > 0) {
    var futures = authorizationFilters
        .map((f) => f.executeAuthorizationFilter(filterContext));

    if (!await _processFilters(futures, context)) {
      return false;
    }
  }

  final actionFilters = _getActionFilters(actionMirror);
  if (actionFilters.length > 0) {
    var futures =
    actionFilters.map((f) => f.executeActionFilter(filterContext));
    if (!await _processFilters(futures, context)) {
      return false;
    }
  }

  return true;
}

Future<bool> _processFilters(
    Iterable<Future> filters, HttpContext context) async {
  bool failed = false;
  for(final filter in filters) {
    try {
      await filter;
      return true;
    } on ActionFilterException {
      failed = true;
    }
  }

  if(failed) {
    context.response
      ..statusCode = HttpStatus.UNAUTHORIZED
      ..close();
    return false;
  }

  return true;
}

final _authenticationFilterType = reflectType(AuthenticationFilter);
Iterable<AuthenticationFilter> _getAuthenticationFilters(
    MethodMirror actionMirror) {
  return actionMirror.metadata
      .where((InstanceMirror annotation) =>
          annotation.type.isSubtypeOf(_authenticationFilterType))
      .map((InstanceMirror annotation) => annotation.reflectee);
}

final _authorizationFilterType = reflectType(AuthorizationFilter);
Iterable<AuthorizationFilter> _getAuthorizationFilters(
    MethodMirror actionMirror) {
  return actionMirror.metadata
      .where((InstanceMirror annotation) =>
          annotation.type.isSubtypeOf(_authorizationFilterType))
      .map((InstanceMirror annotation) => annotation.reflectee);
}

final _actionFilterType = reflectType(ActionFilter);
Iterable<ActionFilter> _getActionFilters(MethodMirror actionMirror) {
  return actionMirror.metadata
      .where((InstanceMirror annotation) =>
          annotation.type.isSubclassOf(_actionFilterType))
      .map((InstanceMirror annotation) => annotation.reflectee);
}
