part of http;

/// Defines the websocket context interface.
///
/// Act property bag for all the needed information
/// when processing a websocket request.
abstract class WebSocketContext {
  HttpContext get httpContext;
}
