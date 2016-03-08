/// The [mvc] library.
library mvc;

import 'dart:async' show Future;
import 'dart:mirrors' show MirrorSystem, reflect;

import 'package:core_mvc/action_result.dart'
    show ActionResult, JsonResult, ResultContext, StringResult;
import 'package:core_mvc/http.dart' show HttpContext;
import 'package:core_mvc/router.dart' show Route;

part 'src/mvc/controller.dart';
part 'src/mvc/model.dart';
