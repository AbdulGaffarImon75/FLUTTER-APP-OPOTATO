import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeatBookingController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Returns current user’s type (“customer”, “restaurant”, etc.) or null.
  Future<String?> fetchCurrentUserType() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['user_type'] as String?;
  }

  /// Fetch all restaurant names and their doc IDs.
  Future<Map<String, String>> fetchRestaurantNames() async {
    final snap =
        await _db
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();
    return {for (var d in snap.docs) (d.data()['name'] as String? ?? ''): d.id};
  }

  /// Fetch seat availability data for a given restaurant doc ID.
  Future<Map<String, int>?> fetchAvailability(String restDocId) async {
    final snap = await _db.collection('rest').doc(restDocId).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return {
      '2': (data['2_people_seat'] ?? 0) as int,
      '4': (data['4_people_seat'] ?? 0) as int,
      '8': (data['8_people_seat'] ?? 0) as int,
      '12': (data['12_people_seat'] ?? 0) as int,
      'available': (data['available seats'] ?? 0) as int,
    };
  }

  /// Compute total seats selected.
  int totalSeatsSelected(int c2, int c4, int c8, int c12) {
    return c2 * 2 + c4 * 4 + c8 * 8 + c12 * 12;
  }

  /// Check whether booking is possible under the availability.
  bool canBook(int c2, int c4, int c8, int c12, Map<String, int> avail) {
    final total = totalSeatsSelected(c2, c4, c8, c12);
    return c2 * 2 <= avail['2']! &&
        c4 * 4 <= avail['4']! &&
        c8 * 8 <= avail['8']! &&
        c12 * 12 <= avail['12']! &&
        total <= avail['available']!;
  }

  /// Perform the booking: decrement seats, record reservation, and award 50 points.
  Future<void> bookTable(
    String restDocId,
    int c2,
    int c4,
    int c8,
    int c12,
    String timeSlot, // e.g., "2pm" | "6pm" | "9pm"
  ) async {
    final total = totalSeatsSelected(c2, c4, c8, c12);
    final restRef = _db.collection('rest').doc(restDocId);

    await restRef.update({
      '2_people_seat': FieldValue.increment(-c2 * 2),
      '4_people_seat': FieldValue.increment(-c4 * 4),
      '8_people_seat': FieldValue.increment(-c8 * 8),
      '12_people_seat': FieldValue.increment(-c12 * 12),
      'available seats': FieldValue.increment(-total),
    });

    final user = _auth.currentUser;
    if (user != null) {
      // Optional reservation record
      await _db.collection('reservations').add({
        'userId': user.uid,
        'restaurantId': restDocId,
        'timeSlot': timeSlot,
        'counts': {'2': c2, '4': c4, '8': c8, '12': c12},
        'totalSeats': total,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Award points
      await _db.collection('user_points').doc(user.uid).set({
        'points': FieldValue.increment(50),
      }, SetOptions(merge: true));
    }
  }
}
