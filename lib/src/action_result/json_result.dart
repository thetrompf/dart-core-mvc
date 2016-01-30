part of action_result;

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
