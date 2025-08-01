import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String adminUID = '9augevirHjVzo8izlXsJba568782';

  /// Public getter so views don’t have to reach into a private field.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Returns 'admin', 'restaurant', or null if not logged in.
  Future<String?> getUserType() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    if (u.uid == adminUID) return 'admin';
    final doc = await _db.collection('users').doc(u.uid).get();
    return doc.data()?['user_type'] as String?;
  }

  /// For restaurants: ensure a doc exists, then return its data.
  Future<Map<String, dynamic>> ensureAndFetchRestaurantDoc(String uid) async {
    final usersnap = await _db.collection('users').doc(uid).get();
    final name = usersnap.data()?['name'] ?? 'Unknown';
    final restRef = _db.collection('restaurants').doc(uid);
    final restSnap = await restRef.get();

    if (!restSnap.exists) {
      await restRef.set({
        'name': name,
        'payment_status': 'Unpaid',
        'total_seats': 0,
        'available_seats': 0,
        '2_people_seat': 0,
        '4_people_seat': 0,
        '8_people_seat': 0,
        '12_people_seat': 0,
      });
    }

    return (await restRef.get()).data()!;
  }

  /// For admin: fetch all restaurants’ payment statuses.
  Future<List<Map<String, dynamic>>> fetchAllRestaurantsStatus() async {
    final snap = await _db.collection('restaurants').get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'name': data['name'] ?? 'Unnamed',
        'payment_status': data['payment_status'] ?? 'Unpaid',
      };
    }).toList();
  }
}
