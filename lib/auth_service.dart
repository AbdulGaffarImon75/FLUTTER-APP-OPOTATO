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
    await _auth.signOut();
  }
}

// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;

//   Future<User?> createUserWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return cred.user;
//     } catch (e) {
//       log("Something went wrong");
//     }
//     return null;
//   }

//   Future<User?> loginUserWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return cred.user;
//     } catch (e) {
//       log("Something went wrong");
//     }
//     return null;
//   }

//   Future<void> signout() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       log("Something went wrong");
//     }
//   }
// }
