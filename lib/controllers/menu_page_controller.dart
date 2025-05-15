import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_model.dart';

class MenuPageController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Expose only the current user’s UID (keep _auth private).
  String? get currentUserId => _auth.currentUser?.uid;

  /// Fetch current user type (e.g. 'customer' or 'restaurant').
  Future<String?> fetchUserType() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] as String?;
  }

  /// Fetch the vendor's display name by their user ID.
  Future<String?> fetchVendorName(String restaurantId) async {
    final doc = await _db.collection('users').doc(restaurantId).get();
    return doc.data()?['name'] as String?;
  }

  /// Retrieve all menu items for a given vendor.
  Future<List<MenuModel>> fetchMenus(String vendorName) async {
    final snap =
        await _db
            .collection('menu')
            .where('vendor', isEqualTo: vendorName)
            .orderBy('segment')
            .get();
    return snap.docs.map((d) => MenuModel.fromMap(d.id, d.data())).toList();
  }

  /// Post a new menu item under the vendor's name.
  Future<void> postMenuItem({
    required String vendorName,
    required String title,
    required String segment,
    required String price,
    required String imageURL,
  }) {
    final data = {
      'title': title.trim(),
      'segment': segment.trim(),
      'price': price.trim(),
      'imageURL': imageURL.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'vendor': vendorName,
    };
    return _db.collection('menu').add(data);
  }

  /// Delete a menu item by document ID.
  Future<void> deleteMenuItem(String docId) {
    return _db.collection('menu').doc(docId).delete();
  }
}
