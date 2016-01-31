part of application;

/// The [Application] class is the entry point
/// where configuration of the application happens
/// the router is initialized and all the routes
/// are added, the handling of http request and websocket request
/// is setup here along with error handling, when a route action
/// throws or if no route was found matching the requested [Uri]
abstract class Application {
  /// The application [router].
  Router get router;

  /// The application root level [logger]
  Logger get logger;

  /// The network [address] is bound to.
  InternetAddress get address;

  /// The network [port] is bound to.
  int get port;

  /// The dependency [injector], the application
  /// utilizes to fire up controllers and their dependencies.
  Injector get injector;

  factory Application(
      {Router router,
      Logger logger,
      InternetAddress address,
      int port,
      Injector injector}) = DefaultApplication;

  /// When start is called, all the network binding
  /// will be started, along with the configuring of the router,
  /// [initializeRouter] is called, and finally
  /// [initializeServer] will be invoked.
  /// after this the application is running and ready for incoming request.
  Future start();

  /// Initialize the [router] by adding routes to [routes].
  Future initializeRouter(List<Route> routes);

  /// Initializing the server, binding the network sockets.
  /// and setting up the incoming request loop for listening
  /// to request, and call the [handleHttpRequest] and [handleWebSocketRequest]
  /// respectively.
  Future<HttpServer> initializeServer();

  /// All incoming http requests will call this method with a [context]
  /// describing the parameters of the http request.
  Future handleHttpRequest(HttpContext context);

  /// All incoming web socket requests will call this method with a [context].
  /// describing the parameters of the web socket request.
  Future handleWebSocketRequest(WebSocketContext context);

  /// This method is called for every uncaught error made by controller code,
  /// the [context] of the request and the [error] thrown is provided.
  Future handleRequestError(HttpContext context, error);

  /// Every request made where no matching route was found will end up
  /// triggering this method to be called with the [context] of the request.
  Future handleRouteNotFound(HttpContext context);

  /// Stop the application gracefully by waiting for all requests to be handled
  /// and not accepting new incoming request, unless [force] is true,
  /// where all request handling will be cancelled and all output sinks
  /// will be closed.
  ///
  /// All websockets will send a disconnect packet unless
  /// the connection is [force] closed.
  Future stop({bool force: false});
}
