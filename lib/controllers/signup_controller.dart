import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';
import 'user_controller.dart';

class SignupController {
  final AuthController _authCtrl = AuthController();
  final UserController _userCtrl = UserController();

  /// Registers a new user, creates their Firestore profile, and returns the Firebase [User].
  Future<User?> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String userType,
    String profileImageUrl = '',
  }) async {
    // 1. Create auth user
    final user = await _authCtrl.register(email, password);
    if (user == null) return null;

    // 2. Build profile data
    final userData = {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'uid': user.uid,
      'user_type': userType,
      'profile_image_url': profileImageUrl.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 3. Persist profile document
    await _userCtrl.createUser(user.uid, userData);
    return user;
  }
}
