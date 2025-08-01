import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_notification_model.dart';

class NotificationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CustomerNotification>> fetchCustomerNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // get restaurants this user follows
    final followedSnapshot =
        await _db
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();
    final followedIds = followedSnapshot.docs.map((d) => d.id).toSet();

    // get all offers, filter by those posted by followed restaurants
    final offersSnap =
        await _db
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    return offersSnap.docs
        .where((doc) => followedIds.contains(doc['posted_by_id']))
        .map((doc) {
          final data = doc.data();
          return CustomerNotification(
            name: data['name'] ?? 'Unnamed Offer',
            price: data['price']?.toString() ?? '',
            imageUrl: data['imageURL'] ?? '',
            postedBy: data['posted_by'] ?? 'Unknown',
            profileImageUrl: data['profile_image_url'] ?? '',
            timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          );
        })
        .toList();
  }
}
