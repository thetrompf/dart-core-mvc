/// The [router] library.
library router;

import 'dart:async' show Future, Stream;
import 'dart:io' show HttpRequest, HttpStatus;
import 'dart:mirrors'
    show ClassMirror, DeclarationMirror, InstanceMirror, LibraryMirror, MethodMirror, MirrorSystem, currentMirrorSystem, reflectClass, reflectType;

import 'package:resem.pl/http.dart' show HttpContext, HttpVerb;
import 'package:resem.pl/ioc.dart' show Injector;
import 'package:resem.pl/mvc.dart' show Controller;
import 'package:resem.pl/action_filter.dart' show ActionFilter, AuthenticationFilter, AuthorizationFilter, FilterContext, FilterPassResult;

part 'src/router/route.dart';
part 'src/router/router.dart';



final ClassMirror controllerMirror = reflectClass(Controller);
final ClassMirror routeMirror = reflectClass(Route);

Iterable<Route> _getLibraryRoutes(LibraryMirror libraryMirror) {
  final routes = [];
  for(final classMirror in libraryMirror.declarations.values) {
    if(classMirror is! ClassMirror || !classMirror.isSubclassOf(controllerMirror)) {
      continue;
    }
    classMirror as ClassMirror;
    for(final methodMirror in classMirror.instanceMembers.values) {
      for(final InstanceMirror annotationMirror in methodMirror.metadata) {
        if(!annotationMirror.type.isSubtypeOf(routeMirror)) {
          continue;
        }
        Route annotation = annotationMirror.reflectee;
        routes.add(new Route(
            library: MirrorSystem.getName(libraryMirror.simpleName),
            controller: MirrorSystem.getName(classMirror.simpleName),
            action: MirrorSystem.getName(methodMirror.simpleName),
            route: annotation.route,
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
