part of mvc;

/// The base controller class/interface.
/// All controllers must extend or implement this interface
/// in order to be a controller that has a action/method called
/// from the [Router] when a route is matched, or be collected
/// as a controller by the route annotation reader.
abstract class Controller {
  Future executeAction(Route route, HttpContext context) async {
    final controllerMirror = reflect(this);
    final resultMirror =
        controllerMirror.invoke(MirrorSystem.getSymbol(route.action), []);
    context.response
      ..statusCode = 200
      ..write(await resultMirror.reflectee)
      ..close();
  }
}
