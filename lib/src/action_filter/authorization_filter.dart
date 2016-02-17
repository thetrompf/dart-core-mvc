part of action_filter;

abstract class AuthorizationFilter {
  Future executeAuthorizationFilter(FilterContext context);
}

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
