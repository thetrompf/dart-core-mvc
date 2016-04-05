/// This library contains the basic classes interfaces
/// to encode data and write to the response object.
///
///     class CensorResult implements ActionResult {
///
///       final String output;
///       CustomResult(this.output);
///
///       Future executeResult(ResultContext context) async {
///         context.response.write(output.replaceAll('Dirty words','Clean words'));
///       }
///
///     }
///
///     class SomeController extends Controller {
///
///       Future<ActionResult> json() async {
///         return jsonResult({'hello':'World'});
///       }
///
///       Future<ActionResult> string() async {
///         return stringResult(r'Hello World');
///       }
///
///       Future<ActionResult> custom() async {
///         return new CensorResult(r'Dirty words');
///       }
///
///     }
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
