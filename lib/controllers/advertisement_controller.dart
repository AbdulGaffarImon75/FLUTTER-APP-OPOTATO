import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvertisementController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns true if the current user exists and has user_type == 'customer'
  Future<bool> isCustomer() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] == 'customer';
  }

  /// Fetches both offers and combos, filters out items by followed restaurant IDs,
  /// and sorts by timestamp desc.
  Future<List<Map<String, dynamic>>> fetchUnfollowedItems() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // get all followed restaurant IDs
    final followSnap =
        await _firestore
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();
    final followedIds = followSnap.docs.map((d) => d.id).toSet();

    // fetch latest offers
    final offersSnap =
        await _firestore
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    // fetch latest combos
    final combosSnap =
        await _firestore
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();

    // map and tag offers
    final offers =
        offersSnap.docs
            .map((doc) {
              final data = doc.data();
              return {
                ...data,
                'type': 'offer',
                'posterId': data['posted_by_id'],
                'poster': data['posted_by'] ?? 'Unknown',
                'title': data['name'] ?? '',
              };
            })
            .where((item) => !followedIds.contains(item['posterId']))
            .toList();

    // map and tag combos
    final combos =
        combosSnap.docs
            .map((doc) {
              final data = doc.data();
              return {
                ...data,
                'type': 'combo',
                'posterId': data['vendor_id'],
                'poster': data['vendor'] ?? 'Unknown',
                'title': data['title'] ?? '',
              };
            })
            .where((item) => !followedIds.contains(item['posterId']))
            .toList();

    // combine and sort by timestamp descending
    final all = [...offers, ...combos];
    all.sort((a, b) {
      final tA = a['timestamp'] as Timestamp;
      final tB = b['timestamp'] as Timestamp;
      return tB.compareTo(tA);
    });
    return all;
  }
}
