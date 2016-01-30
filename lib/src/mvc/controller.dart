part of mvc;

/// The base controller class/interface.
/// All controllers must extend or implement this interface
/// in order to be a controller that has a action/method called
/// from the [Router] when a route is matched, or be collected
/// as a controller by the route annotation reader.
abstract class Controller {
  Future<StringResult> stringResult(String output) async =>
      new StringResult(output);

  Future<JsonResult> jsonResult(Object output) async => new JsonResult(output);

  Future executeAction(Route route, HttpContext context) async {
    final controllerMirror = reflect(this);
    final resultMirror =
        controllerMirror.invoke(MirrorSystem.getSymbol(route.action), []);

    final ActionResult actionResult = await resultMirror.reflectee;

    var resultContext = new ResultContext(httpContext: context);

    return actionResult.executeResult(resultContext);
  }
}
