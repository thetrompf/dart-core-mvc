part of action_result;

/// The base interface action results returned by
/// [Controller] actions.
abstract class ActionResult {

  /// Execute the result, and write it to the response object.
  Future executeResult(ResultContext context);
}
