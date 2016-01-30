part of action_result;

/// The context provided to every [ActionResult].
abstract class ResultContext {
  HttpContext get httpContext;
  HttpResponse get response;
  int get statusCode;
  ContentType get contentType;

  factory ResultContext(
      {HttpContext httpContext,
      int statusCode,
      ContentType contentType}) = _DefaultResultContext;
}

class _DefaultResultContext implements ResultContext {
  final HttpContext httpContext;
  final HttpResponse response;
  final int statusCode;
  final ContentType contentType;

  _DefaultResultContext(
      {httpContext, this.statusCode: 200, ContentType contentType})
      : this.httpContext = httpContext,
        response = httpContext.response,
        this.contentType = contentType ??
            new ContentType('application', 'json', charset: 'utf-8');
}
