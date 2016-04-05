part of action_result;

/// The action result to to use, when want to write plain text to the
/// response object.
class StringResult implements ActionResult {

  final String output;
  StringResult(this.output);

  @override
  Future executeResult(ResultContext context) async {
    context.response
      ..statusCode = context.statusCode
      ..headers.contentType = context.contentType
      ..write(output)
      ..close();
  }
}
