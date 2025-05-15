// lib/controllers/following_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant_follow_model.dart';

class FollowingController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> _isUserCustomer(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['user_type'] == 'customer';
  }

  Future<String> _fetchCustomerName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['name'] ?? 'A user';
  }

  /// Returns list of all restaurants annotated with whether the current user follows them.
  Future<List<RestaurantFollow>> fetchRestaurantsWithFollowStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    if (!await _isUserCustomer(user.uid)) return [];

    final followingSnap =
        await _db
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();
    final followedIds = followingSnap.docs.map((d) => d.id).toSet();

    final allSnap =
        await _db
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();

    final list =
        allSnap.docs.map((doc) {
          final data = doc.data();
          final id = doc.id;
          return RestaurantFollow(
            uid: id,
            name: data['name'] ?? 'Unnamed',
            imageUrl: data['profile_image_url'] ?? '',
            isFollowing: followedIds.contains(id),
          );
        }).toList();

    // Put followed ones first, then sort by name
    list.sort((a, b) {
      if (a.isFollowing && !b.isFollowing) return -1;
      if (!a.isFollowing && b.isFollowing) return 1;
      return a.name.compareTo(b.name);
    });

    return list;
  }

  /// Toggles a follow/unfollow for [restaurantId], and sends a notification to the restaurant.
  Future<void> toggleFollow(String restaurantId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ownUid = user.uid;
    final isCustomer = await _isUserCustomer(ownUid);
    if (!isCustomer) return;

    final custName = await _fetchCustomerName(ownUid);
    final docRef = _db
        .collection('following')
        .doc(ownUid)
        .collection('restaurants')
        .doc(restaurantId);

    final already = (await docRef.get()).exists;

    // Fetch restaurant name
    final restDoc = await _db.collection('users').doc(restaurantId).get();
    final restName = restDoc.data()?['name'] ?? 'Restaurant';

    if (already) {
      await docRef.delete();
      await _db
          .collection('notifications')
          .doc(restaurantId)
          .collection('messages')
          .add({
            'message': 'Dear $restName, $custName has just unfollowed you.',
            'timestamp': FieldValue.serverTimestamp(),
          });
    } else {
      await docRef.set({'timestamp': FieldValue.serverTimestamp()});
      await _db
          .collection('notifications')
          .doc(restaurantId)
          .collection('messages')
          .add({
            'message': 'Dear $restName, $custName has started following you.',
            'timestamp': FieldValue.serverTimestamp(),
          });
    }
  }
}
