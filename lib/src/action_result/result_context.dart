part of action_result;

/// The context provided to every [ActionResult].
/// This context holds the response object to write the results to
/// it also has the [HttpContext] in case info about the connection
/// or request is need.
abstract class ResultContext {

  /// Get the http context.
  HttpContext get httpContext;

  /// The response object to write the result to.
  HttpResponse get response;

  /// The status code that should be written to the response object.
  int get statusCode;

  /// The content type that should be written to the response object.
  ContentType get contentType;

  factory ResultContext(
      {HttpContext httpContext,
      int statusCode,
      ContentType contentType}) = _DefaultResultContext;
}

/// The default implementation of the result context interface.
class _DefaultResultContext implements ResultContext {

  final HttpContext httpContext;
  HttpResponse get response => httpContext.response;
  final int statusCode;
  final ContentType contentType;

  _DefaultResultContext(
      {httpContext, this.statusCode: 200, ContentType contentType})
      : this.httpContext = httpContext,
        this.contentType = contentType ??
            new ContentType('application', 'json', charset: 'utf-8');
}
