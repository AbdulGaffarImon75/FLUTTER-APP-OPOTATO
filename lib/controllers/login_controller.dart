import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';

class LoginController {
  final AuthController _authCtrl = AuthController();

  /// Attempts to sign in; returns the Firebase [User] on success, or null.
  Future<User?> login(String email, String password) {
    return _authCtrl.login(email, password);
  }
}
