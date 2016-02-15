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

  Future processRoute(
      Route route, HttpContext context, Injector injector) async {
    final ms = currentMirrorSystem();
    final LibraryMirror library =
        ms.findLibrary(MirrorSystem.getSymbol(route.library));

    final Symbol controllerSymbol =
        MirrorSystem.getSymbol(route.controller, library);

    final controllerMirror = library.declarations[controllerSymbol] as ClassMirror;
    final authenticationFilters = _getAuthenticationFilters(controllerMirror);

    final filterContext = new FilterContext(httpContext: context);
    final authenticationResult = authenticationFilters.fold(null, (prev, filter) async {
      if(prev != null) {
        return prev;
      }
      return await filter.executeAuthenticationFilter(filterContext);
    });

    if(authenticationResult != null) {
      context.response
        ..statusCode = HttpStatus.UNAUTHORIZED
        ..close();
      return;
    }

    final authorizationFilters = _getAuthorizationFilters(controllerMirror);
    final authorizationResult = authorizationFilters.fold(null, (prev, filter) async {
      if(prev != null) {
        return prev;
      }
      return await filter.executeAuthorizationFilter(filterContext);
    });

    if(authorizationResult != null) {
      context.response
        ..statusCode = HttpStatus.UNAUTHORIZED
        ..close();
      return;
    }

    final actionFilters = _getActionFilters(controllerMirror);
    final filterResult = actionFilters.fold(null, (prev, filter) async {
      if(prev != null) {
        return prev;
      }
      return await filter.executeActionFilter(filterContext);
    });

    if(filterResult != null) {
      context.response
        ..statusCode = HttpStatus.UNAUTHORIZED
        ..close();
      return;
    }

    final Type controllerType = controllerMirror.reflectedType;
    final Controller controller = injector.getType(controllerType);

    await controller.executeAction(route, context);
  }
}

final _authenticationFilterType = reflectType(AuthenticationFilter);
Iterable<AuthenticationFilter> _getAuthenticationFilters(ClassMirror controllerMirror) {
  List<AuthenticationFilter> filters = [];
  for(final actionMirror in controllerMirror.instanceMembers.values) {
    filters.addAll(
      actionMirror.metadata
        .where((InstanceMirror annotation) => annotation.type.isSubtypeOf(_authenticationFilterType))
        .map((InstanceMirror annotation) => annotation.reflectee)
    );
  }
  return filters;
}

final _authorizationFilterType = reflectType(AuthorizationFilter);
Iterable<AuthorizationFilter> _getAuthorizationFilters(ClassMirror controllerMirror) {
  List<AuthorizationFilter> filters = [];
  for(final actionMirror in controllerMirror.instanceMembers.values) {
    filters.addAll(
      actionMirror.metadata
        .where((InstanceMirror annotation) => annotation.type.isSubtypeOf(_authorizationFilterType))
        .map((InstanceMirror annotation) => annotation.reflectee)
    );
  }
  return filters;
}

final _actionFilterType = reflectType(ActionFilter);
Iterable<ActionFilter> _getActionFilters(ClassMirror controllerMirror) {
  List<ActionFilter> filters = [];
  for(final actionMirror in controllerMirror.instanceMembers.values) {
    filters.addAll(
      actionMirror.metadata
        .where((InstanceMirror annotation) => annotation.type.isSubclassOf(_actionFilterType))
        .map((InstanceMirror annotation) => annotation.reflectee)
    );
  }
  return filters;
}
