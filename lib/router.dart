/// The [router] library.
library router;

import 'package:resem.pl/http.dart' show HttpContext, HttpVerb;
import 'package:resem.pl/ioc.dart' show Injector;
import 'package:resem.pl/mvc.dart' show Controller;
import 'dart:async' show Future;
import 'dart:mirrors'
    show DeclarationMirror, LibraryMirror, MirrorSystem, currentMirrorSystem;

part 'src/router/router.dart';
part 'src/router/route.dart';
