import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserDocument(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    await _db.collection('users').doc(uid).set(userData);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> addPoints(String userId, int points) async {
  // This ensures the document exists before incrementing
    await _db.collection('user_points').doc(userId).set({
        'points': FieldValue.increment(points),
      }, SetOptions(merge: true));
    }

    Future<int> getPoints(String userId) async {
      final doc = await _db.collection('user_points').doc(userId).get();
      return doc.exists ? (doc.data()?['points'] ?? 0) : 0;
    }

  Future<bool> redeemPoints(String userId, int points) async {
    final current = await getPoints(userId);
    if (current < points) return false;
    
    await _db.collection('user_points').doc(userId).update({
      'points': FieldValue.increment(-points),
    });
    return true;
  }
}
