/// The [application] library contains the entry classes
/// for booting up a core mvc [Application].
///
/// Please use the [core_mvc] library as entry point, this library is meerly for
/// internal use of the framework.
library application;

import 'dart:async' show Future, Timer;
import 'dart:io' show HttpRequest, HttpServer, HttpStatus, InternetAddress, ProcessSignal;

import 'package:core_mvc/http.dart' show HttpContext, WebSocketContext;
import 'package:core_mvc/ioc.dart' show DefaultInjector, Injector;
import 'package:core_mvc/logger.dart' show Logger;
import 'package:core_mvc/router.dart' show DefaultRouter, Route, Router, addAnnotatedRoutes;

part 'src/application/application.dart';
part 'src/application/default_application.dart';
