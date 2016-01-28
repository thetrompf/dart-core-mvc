/// The [resem.pl] library.
library resem.pl;

export 'package:resem.pl/ioc.dart' show bind, getType;
export 'package:resem.pl/application.dart' show Application;
export 'package:resem.pl/logger.dart'
    show Logger, TtyLogger, JsonLogger, AnsiPen;
export 'package:resem.pl/mvc.dart' show Controller;
export 'package:resem.pl/http.dart' show HttpVerb;
export 'package:resem.pl/router.dart' show Router, DefaultRouter, Route;

//import 'dart:io';
//import 'dart:async';
//
//abstract class Route {
//  String get controller;
//  String get action;
//}
//
//abstract class Router {
//  Route route(Uri uri);
//  bool match(Uri uri);
//}
//
//abstract class HttpContext {
//  Stream get request;
//  StreamSink get response;
//}
//
//Future handler(HttpRequest req, Router router) async {
//
//}
//
//abstract class Application {
//  Router get router;
//
//  factory Application() = _Application;
//}
//
//class _Application implements Application {
//
//  Router _router;
//  Router get router => _router;
//
//  _Application();
//
//  Future start() async {
//    var server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 3300);
//    await for(final HttpRequest req in server) {
//      handler(req, router);
//    }
//  }
//
//}
