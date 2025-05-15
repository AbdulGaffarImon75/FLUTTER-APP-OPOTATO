import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns true if the current user is a customer
  Future<bool> isCustomer() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] == 'customer';
  }

  /// Fetches current user’s name and avatar URL
  Future<Map<String, String?>> fetchUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return {};
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    return {
      'name': data['name'] as String?,
      'image': data['profile_image_url'] as String?,
      'uid': user.uid,
    };
  }

  /// Fetches restaurant’s name and avatar URL
  Future<Map<String, String?>> fetchRestaurantInfo(String restaurantId) async {
    final doc = await _db.collection('users').doc(restaurantId).get();
    final data = doc.data() ?? {};
    return {
      'name': data['name'] as String?,
      'image': data['profile_image_url'] as String?,
    };
  }

  /// Stream of reviews for a given restaurant
  Stream<List<ReviewModel>> reviewsStream(String restaurantId) {
    return _db
        .collection('rest')
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((d) => ReviewModel.fromMap(d.id, d.data()))
                  .toList(),
        );
  }

  /// Posts a new review and awards 30 points
  Future<void> postReview(String restaurantId, String text) async {
    final user = _auth.currentUser;
    if (user == null || text.trim().isEmpty) return;
    final info = await fetchUserInfo();
    await _db.collection('rest').doc(restaurantId).collection('reviews').add({
      'userId': user.uid,
      'userName': info['name'] ?? '',
      'userImage': info['image'] ?? '',
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    // award 30 points
    await _db.collection('user_points').doc(user.uid).set({
      'points': FieldValue.increment(30),
    }, SetOptions(merge: true));
  }
}
