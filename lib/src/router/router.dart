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
    HttpVerb method = new HttpVerb.fromString(req.method);
    for (final Route route in routes) {
      if (route.match(req.uri, method)) {
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

    final Type controllerType =
        (library.declarations[controllerSymbol] as ClassMirror).reflectedType;

    final Controller controller = injector.getType(controllerType);

    await controller.executeAction(route, context);
  }
}
