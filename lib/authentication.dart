/// The authentication library
library authentication;

import 'dart:io' show HttpSession;
import 'dart:async' show Future;

abstract class AuthenticationManager {
  Future<bool> isAuthenticated(HttpSession session);
}
