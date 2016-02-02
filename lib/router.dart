/// The [router] library.
library router;

import 'dart:async' show Future;
import 'dart:io' show HttpRequest;
import 'dart:mirrors'
    show
        ClassMirror,
        DeclarationMirror,
        LibraryMirror,
        MirrorSystem,
        currentMirrorSystem;

import 'package:resem.pl/http.dart' show HttpContext, HttpVerb;
import 'package:resem.pl/ioc.dart' show Injector;
import 'package:resem.pl/mvc.dart' show Controller;

part 'src/router/route.dart';
part 'src/router/router.dart';
