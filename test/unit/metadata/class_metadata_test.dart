library class_metadata_test.unit.core_mvc;

import 'package:test/test.dart';
import 'package:core_mvc/metadata.dart';
import 'package:core_mvc/router.dart';

abstract class AuthenticationFilter implements Annotation {}

class BasicAuthentication implements AuthenticationFilter {
  const BasicAuthentication();
}
class NTLMAuthentication implements AuthenticationFilter {
  const NTLMAuthentication();
}
class OpenAuthentication implements AuthenticationFilter {
  const OpenAuthentication();
}

class OpenAuthentication2 implements AuthenticationFilter {
  const OpenAuthentication2();
}

const BasicAuthentication BasicAuth = const BasicAuthentication();
const NTLMAuthentication NTLMAuth = const NTLMAuthentication();
const OpenAuthentication OAuth = const OpenAuthentication();
const OpenAuthentication2 OAuth2 = const OpenAuthentication2();

abstract class AuthorizationFilter {}

class GenericAuthorization implements AuthorizationFilter {
  final String genericPermission;
  const GenericAuthorization(this.genericPermission);
}

class InheritedAuthorization implements AuthorizationFilter {
  final Type owner;
  const InheritedAuthorization(this.owner);
}
class HierarchicalAuthorization implements AuthorizationFilter {
  final String parentProperty;
  const HierarchicalAuthorization([this.parentProperty = 'parent']);
}

const HierarchicalAuthorization HierarchicalAuthz = const HierarchicalAuthorization();

class Model {}

@BasicAuth @NTLMAuth @OAuth @OAuth2
@GenericAuthorization('Controller')
@InheritedAuthorization(Model)
@HierarchicalAuthz
class Controller {

  @Route(r'/')
  @BasicAuth @NTLMAuth
  void index () {}

}

void main() {
  test('only specified type returned when using Metadata<T>.fromClass constructor', () {
    Iterable<AuthenticationFilter> controllerAuthenticationFilters =
        new Metadata<AuthenticationFilter>.fromClass(Controller);
    expect(controllerAuthenticationFilters, new isInstanceOf<Iterable<AuthenticationFilter>>());
    expect(controllerAuthenticationFilters, hasLength(4), reason: 'The controller class is annotated with 4 AuthenticationFilters');
//    <AuthenticationFilter>[BasicAuth, NTLMAuth, OAuth, OAuth2];
  });
}
