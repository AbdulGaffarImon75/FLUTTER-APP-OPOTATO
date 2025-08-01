import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_controller.dart';
import 'dart:developer' as developer;

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userCtrl = UserController();

  /// Registers a new user with email & password,
  /// then creates their Firestore profile document.
  Future<User?> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await _userCtrl.createUser(user.uid, {
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      developer.log('Registration error: $e');
      if (e is FirebaseAuthException) {
        developer.log('FirebaseAuthException: ${e.message}');
      }
      return null;
    }
  }

  /// Signs in an existing user.
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      developer.log('Login error: $e');
      if (e is FirebaseAuthException) {
        developer.log('FirebaseAuthException: ${e.message}');
      }
      return null;
    }
  }

  /// Re-authenticates to verify the current password.
  Future<bool> validatePassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user != null;
    } catch (e) {
      developer.log('Password validation error: $e');
      return false;
    }
  }

  /// Updates the current user’s password.
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // optional: reload to clear any cached session
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
      }
      developer.log('User signed out');
    } catch (e) {
      developer.log('Sign-out error: $e');
    }
  }
}
