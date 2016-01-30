part of action_result;

class StringResult implements ActionResult {
  final String output;
  StringResult(this.output);

  Future executeResult(ResultContext context) async {
    context.httpContext.response
      ..statusCode = context.statusCode
      ..headers.contentType = context.contentType
      ..write(output)
      ..close();
  }
}
