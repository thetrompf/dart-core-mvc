library demo.core_mvc;

import 'package:core_mvc/core_mvc.dart';
import 'dart:async' show Future;
import 'dart:io' show Platform;

class DemoController extends Controller {

  @Route(r'/')
  Future<ActionResult> index() async {
    return stringResult('Hello, World!');
  }

  @Route(r'/', verb: HttpVerb.POST)
  Future<ActionResult> post() async {
    return jsonResult({'success': true});
  }

}

Future main() async {
  Logger logger;
  if(Platform.environment.containsKey('CORE_MVC_ENV') && Platform.environment['CORE_MVC_ENV'] != 'development') {
    logger = new JsonLogger(group: 'app');
  } else {
    logger = new TtyLogger(
      group: 'app',
      groupColor: AnsiPen.yellow,
      level: DEBUG_LEVEL
    );
  }

  var app = new Application(logger: logger, port: 3330);
  await app.start();
}
