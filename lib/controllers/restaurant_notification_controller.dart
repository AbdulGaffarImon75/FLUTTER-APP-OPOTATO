import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant_notification_model.dart';

class RestaurantNotificationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<RestaurantNotification>> fetchNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snap =
        await _db
            .collection('notifications')
            .doc(user.uid)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return RestaurantNotification(
        message: data['message'] ?? '',
        timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }
}
