/// The [mvc] library.
library mvc;

import 'dart:async' show Future;
import 'dart:mirrors' show MirrorSystem, reflect;

import 'package:resem.pl/action_result.dart'
    show ActionResult, JsonResult, ResultContext, StringResult;
import 'package:resem.pl/http.dart' show HttpContext;
import 'package:resem.pl/router.dart' show Route;

part 'src/mvc/controller.dart';
part 'src/mvc/model.dart';
