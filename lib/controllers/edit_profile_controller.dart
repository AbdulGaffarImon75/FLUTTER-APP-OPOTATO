// controllers/edit_profile_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class EditProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userCtrl = UserController();
  final AuthController _authCtrl = AuthController();

  /// Loads the current user’s profile via UserController.
  Future<UserModel?> fetchUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    // UserController.fetchUser already returns a mapped UserModel
    return await _userCtrl.fetchUser(user.uid);
  }

  /// Updates name, email, phone in Firestore.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) {
    return _userCtrl.updateUser(uid, {
      'name': name,
      'email': email,
      'phone': phone,
    });
  }

  /// Validates and, if valid, changes password.
  Future<bool> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final valid = await _authCtrl.validatePassword(email, currentPassword);
    if (!valid) return false;
    await _authCtrl.changePassword(newPassword);
    return true;
  }
}
