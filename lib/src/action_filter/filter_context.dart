part of action_filter;

abstract class FilterContext {
  HttpContext get httpContext;
  factory FilterContext({HttpContext httpContext}) = DefaultFilterContext;
}

class DefaultFilterContext implements FilterContext {
  final HttpContext httpContext;
  DefaultFilterContext({this.httpContext});
}
