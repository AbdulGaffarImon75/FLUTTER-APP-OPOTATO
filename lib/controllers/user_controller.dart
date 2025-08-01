import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a new user document in `users` collection.
  Future<void> createUser(String uid, Map<String, dynamic> userData) {
    return _db.collection('users').doc(uid).set(userData);
  }

  /// Fetches user data and maps it to UserModel.
  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// Updates fields on the existing user document.
  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  /// Increments the user’s reward points by [points].
  Future<void> addRewardPoints(String userId, int points) {
    return _db.collection('user_points').doc(userId).set({
      'points': FieldValue.increment(points),
    }, SetOptions(merge: true));
  }

  /// Retrieves the current reward points balance.
  Future<int> fetchRewardPoints(String userId) async {
    final doc = await _db.collection('user_points').doc(userId).get();
    return doc.exists ? (doc.data()?['points'] as int? ?? 0) : 0;
  }

  /// Deducts [points] if available; returns true on success.
  Future<bool> redeemRewardPoints(String userId, int points) async {
    final current = await fetchRewardPoints(userId);
    if (current < points) return false;
    await _db.collection('user_points').doc(userId).update({
      'points': FieldValue.increment(-points),
    });
    return true;
  }
}
