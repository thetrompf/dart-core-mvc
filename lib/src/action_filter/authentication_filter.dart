part of action_filter;

abstract class AuthenticationFilter {
  Future executeAuthenticationFilter(FilterContext context);
}

class CompositeAuthenticationRequired implements AuthenticationFilter {

  final Iterable<AuthenticationFilter> filters;
  const CompositeAuthenticationRequired(this.filters);

  @override
  Future executeAuthenticationFilter(FilterContext context) {
    return filters.fold(null, (prev, filter) async {
      await prev;
      return filter.executeAuthenticationFilter(context);
    });
  }
}

const AuthenticationRequired = const DefaultAuthenticationRequired();
class DefaultAuthenticationRequired implements AuthenticationFilter {
  const DefaultAuthenticationRequired();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const PasswordAuthenticationRequired = const DefaultPasswordAuthenticationRequired();
class DefaultPasswordAuthenticationRequired implements AuthenticationFilter {
  const DefaultPasswordAuthenticationRequired();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}

const AnonymousRequired = const DefaultAnonymousRequired();
class DefaultAnonymousRequired implements AuthenticationFilter {
  const DefaultAnonymousRequired();

  @override
  Future executeAuthenticationFilter(FilterContext context) async {
    return null;
  }
}
