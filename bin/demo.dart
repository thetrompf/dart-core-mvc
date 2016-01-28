import 'package:resem.pl/resem.pl.dart';
import 'dart:async' show Future, Timer;
import 'package:resem.pl/logger.dart';

//import 'package:resem.pl/resem.pl.dart' show bind, getType;
//import 'dart:io';
//
//abstract class DatabaseConnection {}
//class PostgreSqlDatabaseConnection implements DatabaseConnection {}
//
//abstract class EntityManager {}
//class DefaultEntityManager implements EntityManager {
//  final DatabaseConnection conn;
//  DefaultEntityManager(this.conn);
//}
//
//abstract class AuthenticationManager {}
//class DefaultAuthenticationManager extends AuthenticationManager {
//  final EntityManager em;
//  DefaultAuthenticationManager(this.em);
//}
//
//abstract class AuthorizationManager {}
//class DefaultAuthorizationManager extends AuthorizationManager {
//  final EntityManager em;
//  final AuthenticationManager authn;
//  DefaultAuthorizationManager(this.em, this.authn);
//}
//
//abstract class Controller {}
//class HomeController extends Controller {
//  final EntityManager em;
//  final AuthenticationManager authn;
//  final AuthorizationManager authz;
//  HomeController(this.em, this.authn, this.authz);
//}

Future main() async {
  
//  bind(DatabaseConnection).to(new PostgreSqlDatabaseConnection());
//  bind(EntityManager).to(DefaultEntityManager);
//  bind(AuthorizationManager).to(DefaultAuthorizationManager);
//  bind(AuthenticationManager).to(DefaultAuthenticationManager);
//
//  var controller = getType(HomeController);
//  print(controller);
//
//  return;
  Logger iocLogger = new TtyLogger(
      group: 'injector', groupColor: AnsiPen.magenta, level: DEBUG_LEVEL);
  Logger logger = new TtyLogger(
      group: 'app', groupColor: AnsiPen.yellow, level: VERBOSE_LEVEL);
  Logger routerLogger = new TtyLogger(
      group: 'router', groupColor: AnsiPen.blue, level: SUCCESS_LEVEL);
  new Timer.periodic(const Duration(seconds: 2), (_) {
    iocLogger.debug('hans');
  });

  new Timer.periodic(const Duration(seconds: 5), (_) {
    routerLogger.success("Incoming request at '/'");
  });

  var app = new Application(router: null, logger: logger, port: 3330);
  try {
    await app.start();
  } catch (e) {
    print(e);
  }
}
