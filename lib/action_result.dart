/// The [action_result] library.
library action_result;

import 'dart:async' show Future;
import 'package:resem.pl/http.dart' show HttpContext;
import 'dart:io' show ContentType, HttpResponse;
import 'dart:convert';

part 'src/action_result/action_result.dart';
part 'src/action_result/result_context.dart';
part 'src/action_result/string_result.dart';
part 'src/action_result/json_result.dart';

abstract class Encodable {
  Map encode(Set visited);
}
