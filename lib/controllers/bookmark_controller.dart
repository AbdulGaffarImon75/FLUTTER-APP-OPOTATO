// lib/controllers/bookmark_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bookmark_model.dart';

class BookmarkController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams the list of bookmarks for the current user.
  Stream<List<BookmarkModel>> streamBookmarks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) {
                final data = doc.data();
                return BookmarkModel(
                  id: doc.id,
                  title: data['title'] ?? '',
                  price: data['price'] ?? '',
                  vendor: data['vendor'] ?? '',
                  imageUrl: data['imageURL'] ?? '',
                );
              }).toList(),
        );
  }

  /// Removes a bookmark by its document ID.
  Future<void> removeBookmark(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();
  }
}
