part of action_result;

/// JsonResult converts objects that are JSON serializable
/// and writes it to the response object.
class JsonResult implements ActionResult {

  final Object output;
  JsonResult(this.output);

  @override
  Future executeResult(ResultContext context) async {
    context.response
      ..headers.contentType = context.contentType
      ..statusCode = context.statusCode
      ..write(JSON.encode(output))
      ..close();
  }
}
