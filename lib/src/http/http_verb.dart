part of http;

ClassMirror _VerbMirror = reflectClass(HttpVerb);

/// The enum containing all http verbs
/// supported by this framework.
class HttpVerb extends Enum<String> {
  static const GET = const HttpVerb('GET');
  static const PUT = const HttpVerb('PUT');
  static const POST = const HttpVerb('POST');
  static const PATCH = const HttpVerb('PATCH');
  static const DELETE = const HttpVerb('DELETE');
  static const OPTIONS = const HttpVerb('OPTIONS');

  const HttpVerb(String value) : super(value);

  factory HttpVerb.fromString(String type) =>
      new Enum.fromString(type.toUpperCase(), _VerbMirror);

  String toString() => super.enumToString(_VerbMirror);

  bool operator ==(other) {
    if (other is String) {
      return value == other;
    }
    return super == (other);
  }
}
