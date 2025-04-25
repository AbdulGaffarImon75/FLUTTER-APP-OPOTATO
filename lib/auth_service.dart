import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _userService.createUserDocument(cred.user!.uid, {
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return cred.user;
    } catch (e) {
      developer.log("Auth error: $e");
      if (e is FirebaseAuthException) {
        developer.log("FirebaseAuthException: ${e.message}");
      }
      return null;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      developer.log("Login error: $e");
      if (e is FirebaseAuthException) {
        developer.log("FirebaseAuthException: ${e.message}");
      }
      return null;
    }
  }

  Future<bool> validateCurrentPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user != null;
    } catch (e) {
      developer.log("Password validation error: $e");
      return false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Reload to clear session
      }
      developer.log("User signed out and session reloaded");
    } catch (e) {
      developer.log("SignOut error: $e");
    }
  }
}
