part of action_filter;

/// The interface of an action filter.
/// Controller actions annotated with a class
/// implementing or extending this class will be collected by the [Router]
/// and run before executing the controller action.
///
/// If a single filter fails the controller action will not be executed
/// and the request will stop and notify the user with content
/// for the resulting [FilterResult].
abstract class ActionFilter implements Annotation {

  /// This callback is invoked by the [Router]
  /// in the action result lifecycle phase of the application.
  Future executeActionFilter(FilterContext context);
}

