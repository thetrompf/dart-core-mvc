/// The [application] library contains the entry classes
/// for booting up a resem.pl [Application].
///
/// Please use the [resem.pl] library as entry point, this library is meerly for
/// internal use of the framework.
library application;

import 'dart:io' show HttpRequest, HttpServer, HttpStatus, InternetAddress;
import 'dart:async' show Future, Timer;

import 'package:resem.pl/router.dart' show DefaultRouter, Route, Router;
import 'package:resem.pl/logger.dart' show Logger;
import 'package:resem.pl/http.dart' show HttpContext, WebSocketContext;
import 'package:resem.pl/ioc.dart' show DefaultInjector, Injector;

part 'src/application/application.dart';
part 'src/application/default_application.dart';
