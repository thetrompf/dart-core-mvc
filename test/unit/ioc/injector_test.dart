library ioc_injector_test.unit.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/ioc.dart' show Injector, DefaultInjector, bind;

abstract class DatabaseConnection {
  String get host;
  String get user;
  int get port;
}

abstract class EntityManager {
  DatabaseConnection get conn;
}

abstract class AuthenticationManager {
  EntityManager get em;
}

abstract class AuthorizationManager {
  EntityManager get em;
}

abstract class Controller {}

class TestDatabaseConnection implements DatabaseConnection {
  final String host;
  final String user;
  String _password;
  final int port;
  TestDatabaseConnection({this.host, this.user, String password, this.port})
      : _password = password;
}

class TestEntityManager implements EntityManager {
  final DatabaseConnection conn;
  TestEntityManager(this.conn);
}

class TestAuthenticationManager implements AuthenticationManager {
  final EntityManager em;
  TestAuthenticationManager(this.em);
}

class TestAuthorizationManager implements AuthorizationManager {
  final EntityManager em;
  TestAuthorizationManager(this.em);
}

class TestController {
  final EntityManager em;
  final AuthenticationManager authn;
  final AuthorizationManager authz;

  TestController(this.em, this.authn, this.authz);
}

DatabaseConnection createTestConn() => new TestDatabaseConnection(
    host: 'localhost', user: 'test', password: 'test', port: 1234);

void main() {
  group('Unit', () {
    group('IOC', () {
      group('Injector', () {
        Injector injector;
        setUp(() {
          injector = new DefaultInjector();
        });

        test('concrete is returned by getType', () {
          var testConn = createTestConn();
          bind(DatabaseConnection).to(testConn);
          var resolvedConn = injector.getType(DatabaseConnection);
          expect(testConn, same(resolvedConn));
        });

        test('abstract type can be resolved when all parameters is bound', () {
          var testConn = createTestConn();
          bind(DatabaseConnection).to(testConn);
          bind(EntityManager).to(TestEntityManager);

          var resolved = injector.getType(EntityManager) as TestEntityManager;
          expect(resolved, new isInstanceOf<EntityManager>());
          expect(resolved, new isInstanceOf<TestEntityManager>());
          expect(resolved.conn, same(testConn));
        });

        test(
            'mixed abstract and concrete type can be resolved when all parameters is bound',
            () {
          var testConn = createTestConn();
          bind(DatabaseConnection).to(testConn);
          bind(EntityManager).to(TestEntityManager);
          bind(AuthenticationManager).to(TestAuthenticationManager);

          var resolved =
              injector.getType(AuthenticationManager) as AuthenticationManager;
          expect(resolved, new isInstanceOf<AuthenticationManager>());
          expect(resolved, new isInstanceOf<TestAuthenticationManager>());
          expect(resolved.em, new isInstanceOf<EntityManager>());
          expect(resolved.em, new isInstanceOf<TestEntityManager>());
          expect(resolved.em.conn, new isInstanceOf<DatabaseConnection>());
          expect(resolved.em.conn, new isInstanceOf<TestDatabaseConnection>());
        });

        test(
            'non-bound types can be resolved as long dependencies in the graph are bound',
            () {
          var testConn = createTestConn();
          bind(DatabaseConnection).to(testConn);
          bind(EntityManager).to(TestEntityManager);
          bind(AuthenticationManager).to(TestAuthenticationManager);
          bind(AuthorizationManager).to(TestAuthorizationManager);

          var resolved = injector.getType(TestController) as TestController;
          expect(resolved, new isInstanceOf<TestController>());
        });

        tearDown(() {
          injector = null;
        });
      });
    });
  });
}
