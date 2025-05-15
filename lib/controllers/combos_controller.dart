// controllers/combos_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/combo_model.dart';

class CombosController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all combos, newest first.
  Future<List<ComboModel>> fetchCombos() async {
    final snap =
        await _firestore
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();
    return snap.docs.map((doc) => ComboModel.fromMap(doc.data())).toList();
  }

  /// Returns the set of titles the user has bookmarked.
  Future<Set<String>> fetchBookmarkedTitles(String userId) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('bookmarks')
            .get();
    return snap.docs.map((d) => (d.data()['title'] as String? ?? '')).toSet();
  }

  /// True if the given user is a customer.
  Future<bool> isCustomer(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['user_type'] == 'customer';
  }

  /// Toggles bookmark state for [combo].
  Future<void> toggleBookmark(
    String userId,
    ComboModel combo,
    bool currentlyBookmarked,
  ) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc('${combo.title}-combo');

    if (currentlyBookmarked) {
      await ref.delete();
    } else {
      await ref.set({
        'type': 'combo',
        'title': combo.title,
        'vendor': combo.vendor,
        'price': combo.price,
        'imageURL': combo.imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
