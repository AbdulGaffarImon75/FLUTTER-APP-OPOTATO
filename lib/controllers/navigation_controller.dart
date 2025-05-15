import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NavigationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Same admin UID across app
  static const String adminUID = '9augevirHjVzo8izlXsJba568782';

  /// Returns the current Firebase user, or null if not signed in
  User? getCurrentUser() => _auth.currentUser;

  /// Determines the user’s type: guest, admin, restaurant, or customer
  Future<String> getUserType() async {
    final user = _auth.currentUser;
    if (user == null) return 'guest';
    if (user.uid == adminUID) return 'admin';
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] as String? ?? 'unknown';
  }
}
