/// The [http] library.
library http;

import 'dart:io' show HttpConnectionInfo, HttpRequest, HttpResponse;
import 'dart:mirrors' show reflectClass, ClassMirror;

import 'package:core_mvc/type.dart' show Enum;

part 'src/http/http_context.dart';
part 'src/http/http_verb.dart';
part 'src/http/websocket_context.dart';
