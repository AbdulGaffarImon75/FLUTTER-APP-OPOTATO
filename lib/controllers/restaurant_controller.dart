// controllers/restaurant_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant_model.dart';
import '../models/offer_model.dart';
import '../models/combo_model.dart';

class RestaurantController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Load basic restaurant info.
  Future<RestaurantModel?> fetchRestaurant(String restaurantId) async {
    final doc = await _db.collection('users').doc(restaurantId).get();
    if (!doc.exists) return null;
    // only pass the map to fromMap, since our factory expects just the data
    return RestaurantModel.fromMap(doc.data()!);
  }

  /// Load a user’s display name.
  Future<String> fetchUserName(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['name'] as String? ?? '';
  }

  /// Check if current user is a customer.
  Future<bool> isCustomer(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['user_type'] == 'customer';
  }

  /// Check if the customer already follows this restaurant.
  Future<bool> fetchFollowStatus(String userId, String restaurantId) async {
    final doc =
        await _db
            .collection('following')
            .doc(userId)
            .collection('restaurants')
            .doc(restaurantId)
            .get();
    return doc.exists;
  }

  /// Toggle follow/unfollow and send a notification.
  Future<void> toggleFollow({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required String customerName,
    required bool currentlyFollowing,
  }) async {
    final followRef = _db
        .collection('following')
        .doc(userId)
        .collection('restaurants')
        .doc(restaurantId);
    final notifCol = _db
        .collection('notifications')
        .doc(restaurantId)
        .collection('messages');

    if (currentlyFollowing) {
      await followRef.delete();
      await notifCol.add({
        'message':
            'Dear $restaurantName, $customerName has just unfollowed you.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await followRef.set({'timestamp': FieldValue.serverTimestamp()});
      await notifCol.add({
        'message':
            'Dear $restaurantName, $customerName has started following you.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Check if the customer is checked-in here.
  Future<bool> fetchCheckInStatus(String userId, String restaurantId) async {
    final snap =
        await _db
            .collection('check-ins')
            .where('customer_id', isEqualTo: userId)
            .where('restaurant_id', isEqualTo: restaurantId)
            .get();
    return snap.docs.isNotEmpty;
  }

  /// Toggle check-in/out.
  Future<void> toggleCheckIn({
    required String userId,
    required String customerName,
    required String restaurantId,
    required String restaurantName,
    required bool currentlyCheckedIn,
  }) async {
    final coll = _db.collection('check-ins');
    final snap =
        await coll
            .where('customer_id', isEqualTo: userId)
            .where('restaurant_id', isEqualTo: restaurantId)
            .get();

    if (currentlyCheckedIn && snap.docs.isNotEmpty) {
      for (var d in snap.docs) {
        await coll.doc(d.id).delete();
      }
    } else {
      await coll.add({
        'customer_id': userId,
        'customer_name': customerName,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Fetch this restaurant’s offers.
  Future<List<OfferModel>> fetchOffers(String restaurantId) async {
    final snap =
        await _db
            .collection('offers')
            .where('posted_by_id', isEqualTo: restaurantId)
            .orderBy('timestamp', descending: true)
            .get();
    return snap.docs.map((d) => OfferModel.fromMap(d.data())).toList();
  }

  /// Fetch this restaurant’s combos.
  Future<List<ComboModel>> fetchCombos(String restaurantName) async {
    final snap =
        await _db
            .collection('combos')
            .where('vendor', isEqualTo: restaurantName)
            .orderBy('timestamp', descending: true)
            .get();
    return snap.docs.map((d) => ComboModel.fromMap(d.data())).toList();
  }
}
