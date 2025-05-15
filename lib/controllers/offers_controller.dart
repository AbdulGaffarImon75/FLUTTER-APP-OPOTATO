import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/offer_model.dart';

class OffersController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns true if the current user is a customer.
  Future<bool> isCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] == 'customer';
  }

  /// Fetches all offers ordered by timestamp desc.
  Future<List<OfferModel>> fetchOffers() async {
    final snapshot =
        await _db
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => OfferModel.fromDocument(doc)).toList();
  }

  /// Fetches set of bookmarked offer titles for the current user.
  Future<Set<String>> fetchBookmarkedTitles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final snapshot =
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .get();

    return snapshot.docs
        .map((d) => (d.data()['title'] as String?) ?? '')
        .toSet();
  }

  /// Toggles bookmark for [offer].
  Future<void> toggleBookmark(OfferModel offer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookmarkRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${offer.title}-offer');

    final exists = (await bookmarkRef.get()).exists;

    if (exists) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'type': 'offer',
        'title': offer.title,
        'price': offer.price,
        'imageURL': offer.imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
