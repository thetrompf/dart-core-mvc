part of action_filter;

/// The base interface of authorization filters.
abstract class AuthorizationFilter implements Annotation {

  /// This callback is called in the authorization filter lifecycle stage
  /// by the router.
  Future executeAuthorizationFilter(FilterContext context);
}

/// This composite authorization filter implementation
/// allows combining two existing authorization filters and defining that all
/// authorization filters should contained in [filters] should pass through
/// in order for the composite filter to pass.
///
/// *NB!* The usage of this option is only encourage when multiple simple
/// filters do already exist and you simply wants to combine them.
/// If however they do not already exist it is highly recommended just
/// to implement a single authorization filter.
///
///     class SomeController {
///       @CompositeAuthorizationRequired(const [@AuthFilter1, @AuthFilter2])
///       ActionResult index() {
///         return stringResult('hello world');
///       }
///     }
class CompositeAuthorizationRequired implements AuthorizationFilter {

  final Iterable<AuthorizationFilter> filters;
  const CompositeAuthorizationRequired(this.filters);

  @override
  Future executeAuthorizationFilter(FilterContext context) {
    return filters.fold(null, (prev, filter) async {
      await prev;
      return filter.executeAuthorizationFilter(context);
    });
  }
}
