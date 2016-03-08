/// The [router] library.
library router;

import 'dart:async' show Future, Stream;
import 'dart:io' show HttpRequest, HttpStatus;
import 'dart:mirrors'
    show ClassMirror, DeclarationMirror, InstanceMirror, LibraryMirror, MethodMirror, MirrorSystem, currentMirrorSystem, reflectClass, reflectType;

import 'package:core_mvc/http.dart' show HttpContext, HttpVerb;
import 'package:core_mvc/ioc.dart' show Injector;
import 'package:core_mvc/mvc.dart' show Controller;
import 'package:core_mvc/action_filter.dart' show ActionFilter, ActionFilterException, AuthenticationFilter, AuthenticationFilterContext, AuthorizationFilter, FilterContext;
import 'package:core_mvc/metadata.dart' show Annotation, Metadata;

part 'src/router/route.dart';
part 'src/router/router.dart';

final ClassMirror controllerMirror = reflectClass(Controller);

Iterable<Route> _getLibraryRoutes(LibraryMirror libraryMirror) {
  final routes = [];
  for(final classMirror in libraryMirror.declarations.values) {
    if(classMirror is! ClassMirror || !classMirror.isSubclassOf(controllerMirror)) {
      continue;
    }
    classMirror as ClassMirror;
    for(final methodMirror in classMirror.instanceMembers.values) {
      for(final Route annotation in new Metadata<Route>.fromMethodMirror(methodMirror)) {
        routes.add(new Route(
            annotation.route,
            library: MirrorSystem.getName(libraryMirror.simpleName),
            controller: MirrorSystem.getName(classMirror.simpleName),
            action: MirrorSystem.getName(methodMirror.simpleName),
            verb: annotation.verb
        ));
      }
    }
  }
  return routes;
}

void addAnnotatedRoutes(List<Route> routes, [List<String> libraries]) {
  final mirrorSystem = currentMirrorSystem();

  Iterable<LibraryMirror> libs;
  if(libraries == null) {
    libs = mirrorSystem.libraries.values;
  } else {
    libs = libraries.map((library) => MirrorSystem.getSymbol(library));
  }

  libs.forEach((LibraryMirror libraryMirror) =>
      routes.addAll(_getLibraryRoutes(libraryMirror))
  );
}
