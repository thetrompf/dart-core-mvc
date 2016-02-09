library demo.resem.pl;

import 'package:resem.pl/resem.pl.dart' show DefaultApplication, Controller, Router, Route;
import 'dart:async' show Future;
import 'package:resem.pl/logger.dart' show Logger, TtyLogger, AnsiPen, VERBOSE_LEVEL;
import 'package:resem.pl/action_result.dart' show StringResult;

class DemoController extends Controller {
  Future<StringResult> index() async {
    return stringResult('Hello, Demo!');
  }
}

class DemoApplication extends DefaultApplication {
  DemoApplication({Logger logger, int port}) : super(logger: logger, port: port);

  Future initializeRouter(List<Route> routes) async {
    routes.add(const Route(route: r'/', library: 'demo.resem.pl', controller: 'DemoController', action: 'index'));
  }
}

Future main() async {
  Logger logger = new TtyLogger(
      group: 'app', groupColor: AnsiPen.yellow, level: VERBOSE_LEVEL, color: false);

  var app = new DemoApplication(logger: logger, port: 3330);
  try {
    await app.start();
  } catch (e) {
    print(e);
  }
}
