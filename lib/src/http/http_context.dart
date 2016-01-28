part of http;

/// When a request is processed, the context passed around
/// to every component that should react based on the incoming
/// request.
///
/// This context provides information about the request
/// such as information about the URL via [Uri], header
/// information can be retrieved via the [HttpRequest].
///
/// The result of this [request] is then written to [response]
/// usually by a controller action or error handler.
abstract class HttpContext {
  /// The incoming request context
  HttpRequest get request;

  /// The response context of the current request.
  HttpResponse get response;

  /// The information about the connection.
  HttpConnectionInfo get connectionInfo;

  /// The current request [uri].
  Uri get uri;

  factory HttpContext(
      {HttpRequest request,
      HttpResponse response,
      HttpConnectionInfo connectionInfo,
      Uri uri}) = _DefaultHttpContext;
}

/// The default implementation of the [HttpContext].
/// It is essentially just a property bag, with no functionality
/// other than it holds the [request] and [response] information.
class _DefaultHttpContext implements HttpContext {
  final HttpRequest request;
  final HttpResponse response;
  final HttpConnectionInfo connectionInfo;
  final Uri uri;

  _DefaultHttpContext(
      {this.request, this.response, this.connectionInfo, this.uri});
}
