// lib/controllers/checkin_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/checkin_model.dart';

class CheckInController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all check‐ins for the currently authenticated user,
  /// enriching each with the restaurant’s name & image.
  Future<List<CheckIn>> fetchUserCheckIns() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot =
        await _db
            .collection('check-ins')
            .where('customer_id', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    final List<CheckIn> list = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rid = data['restaurant_id'] as String?;
      final ts = data['timestamp'] as Timestamp?;
      if (rid == null || ts == null) continue;

      // look up the restaurant document
      final restDoc = await _db.collection('users').doc(rid).get();
      final rest = restDoc.data() ?? {};
      list.add(
        CheckIn(
          restaurantId: rid,
          restaurantName: rest['name'] ?? 'Restaurant',
          imageUrl: rest['profile_image_url'] ?? '',
          timestamp: ts.toDate(),
        ),
      );
    }
    return list;
  }
}
