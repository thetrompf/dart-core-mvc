/// The [application] library contains the entry classes
/// for booting up a resem.pl [Application].
///
/// Please use the [resem.pl] library as entry point, this library is meerly for
/// internal use of the framework.
library application;

import 'dart:io' show HttpRequest, HttpServer, HttpStatus, InternetAddress;
import 'dart:async' show Future;

import 'package:resem.pl/router.dart' show DefaultRouter, Route, Router;
import 'package:resem.pl/logger.dart' show Logger;
import 'package:resem.pl/http.dart' show HttpContext, WebSocketContext;
import 'package:resem.pl/ioc.dart' show DefaultInjector, Injector;
import 'package:resem.pl/http.dart';
import 'package:resem.pl/ioc.dart';

abstract class Application {
  Router get router;
  Logger get logger;
  InternetAddress get address;
  Injector get injector;
  int get port;

  factory Application(
      {Router router,
      Logger logger,
      InternetAddress address,
      int port,
      Injector injector}) = DefaultApplication;

  Future start();
  Future initializeRouter(List<Route> routes);
  Future initializeServer();
  Future handleHttpRequest(HttpContext context);
  Future handleWebSocketRequest(WebSocketContext context);
  Future handleRequestError(HttpContext context, error);
  Future handleRouteNotFound(HttpContext context);
  Future stop({bool force: false});
}

class DefaultApplication implements Application {
  final Router router;
  final InternetAddress address;
  final int port;
  final Logger logger;
  final Injector injector;
  HttpServer _server;

  DefaultApplication({router, this.logger, address, this.port: 443, injector})
      : this.address = address ?? InternetAddress.ANY_IP_V4,
        this.router = router ?? new DefaultRouter(<Route>[]),
        this.injector = injector ?? new DefaultInjector();

  @override
  Future start() async {
    try {
      await initializeRouter(router.routes);
      return initializeServer();
    } on Error catch (e) {
      logger.error(e.toString());
    }
  }

  @override
  Future initializeRouter(List<Route> routes) async {}

  @override
  Future initializeServer() async {
    logger.debug('Starting server');
    var future = HttpServer.bind(address, port);
    future.then((HttpServer server) async {
      logger.info("Server started listening on ${address.address}:${port}");

      _server = server;
      await for (final HttpRequest req in _server) {
        var context = new HttpContext(
            request: req,
            response: req.response,
            connectionInfo: req.connectionInfo,
            uri: req.uri);

        try {
          await handleHttpRequest(context);
        } catch (error) {
          handleRequestError(context, error);
        }
      }
    });

    return future;
  }

  @override
  Future handleRequestError(HttpContext context, error) async {
    context.response
      ..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
      ..write(error)
      ..close();
  }

  @override
  Future handleHttpRequest(HttpContext context) async {
    var route = await router.route(context.uri);
    if (route == null) {
      await handleRouteNotFound(context);
    } else {
      await router.processRoute(route, context, injector);
    }
  }

  @override
  Future handleWebSocketRequest(WebSocketContext context) async {
    // TODO: implement handleWebSocketRequest
  }

  @override
  Future handleRouteNotFound(HttpContext context) async {
    context.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..write('Route not found')
      ..close();
  }

  @override
  Future stop({bool force: false}) async {
    logger.debug('Shutting down');
    var future = _server.close(force: force);

    future.then((_) => logger.info('Application shutted down'),
        onError: (e) => logger.error(e));

    return future;
  }
}
