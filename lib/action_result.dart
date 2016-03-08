/// The [action_result] library.
library action_result;

import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io' show ContentType, HttpResponse;

import 'package:core_mvc/http.dart' show HttpContext;

part 'src/action_result/action_result.dart';
part 'src/action_result/json_result.dart';
part 'src/action_result/result_context.dart';
part 'src/action_result/string_result.dart';

abstract class Encodable {
  Map encode(Set visited);
}
