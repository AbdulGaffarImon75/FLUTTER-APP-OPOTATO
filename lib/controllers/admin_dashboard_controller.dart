// controllers/admin_dashboard_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_admin_model.dart';
import '../models/offer_model.dart';

class AdminDashboardController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all restaurants (users with user_type == 'restaurant')
  Future<List<RestaurantAdminModel>> fetchRestaurants() async {
    final snap =
        await _db
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();
    return snap.docs.map(RestaurantAdminModel.fromDocument).toList();
  }

  /// Fetch all offers, newest first
  Future<List<OfferModel>> fetchOffers() async {
    final snap =
        await _db
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();
    return snap.docs.map(OfferModel.fromDocument).toList();
  }

  /// Remove a restaurant and all its related data
  Future<void> removeRestaurant(String uid) async {
    // delete the user document
    await _db.collection('users').doc(uid).delete();
    // delete any seat‐tracking doc
    await _db.collection('rest').doc(uid).delete();

    // delete any offers posted by this restaurant
    final offers =
        await _db
            .collection('offers')
            .where('posted_by_id', isEqualTo: uid)
            .get();
    for (var doc in offers.docs) {
      await doc.reference.delete();
    }
  }

  /// Remove a single offer
  Future<void> removeOffer(String id) {
    return _db.collection('offers').doc(id).delete();
  }
}
