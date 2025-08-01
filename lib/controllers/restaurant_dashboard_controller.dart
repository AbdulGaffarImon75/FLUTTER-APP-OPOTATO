import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/offer_model.dart';
import '../models/combo_model.dart';
import '../models/seat_status_model.dart';

class DashboardData {
  final String restaurantName;
  final String profileImageUrl;
  final String restaurantUID;
  final SeatStatusModel seatStatus;
  final List<OfferModel> offers;
  final List<ComboModel> combos;

  DashboardData({
    required this.restaurantName,
    required this.profileImageUrl,
    required this.restaurantUID,
    required this.seatStatus,
    required this.offers,
    required this.combos,
  });
}

class RestaurantDashboardController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<DashboardData?> loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final uid = user.uid;
    final userDoc = await _db.collection('users').doc(uid).get();
    final u = userDoc.data()!;
    final name = u['name'] as String? ?? '';
    final profile = u['profile_image_url'] as String? ?? '';

    // seats collection under "rest"
    final restRef = _db.collection('rest').doc(uid);
    final restSnap = await restRef.get();
    SeatStatusModel seats;
    if (!restSnap.exists) {
      // initialize with defaults
      seats = SeatStatusModel(
        total: 76,
        available: 76,
        two: 12,
        four: 16,
        eight: 24,
        twelve: 24,
      );
      await restRef.set(seats.toMap());
    } else {
      seats = SeatStatusModel.fromMap(restSnap.data()!);
    }

    // fetch this restaurant's offers
    final offersSnap =
        await _db
            .collection('offers')
            .where('posted_by', isEqualTo: name)
            .orderBy('timestamp', descending: true)
            .get();
    final offers =
        offersSnap.docs
            .map((d) => OfferModel.fromMap(d.data()..['id'] = d.id))
            .toList();

    // fetch combos
    final combosSnap =
        await _db
            .collection('combos')
            .where('vendor', isEqualTo: name)
            .orderBy('timestamp', descending: true)
            .get();
    final combos =
        combosSnap.docs
            .map((d) => ComboModel.fromMap(d.data()..['id'] = d.id))
            .toList();

    return DashboardData(
      restaurantName: name,
      profileImageUrl: profile,
      restaurantUID: uid,
      seatStatus: seats,
      offers: offers,
      combos: combos,
    );
  }

  Future<void> postOffer(
    String name,
    String price,
    String imageUrl,
    DashboardData data,
  ) {
    return _db.collection('offers').add({
      'name': name,
      'price': '৳$price',
      'imageURL': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'posted_by': data.restaurantName,
      'posted_by_id': data.restaurantUID,
      'profile_image_url': data.profileImageUrl,
    });
  }

  Future<void> deleteOffer(String offerId) {
    return _db.collection('offers').doc(offerId).delete();
  }

  Future<void> postCombo(
    String title,
    String price,
    String imageUrl,
    DashboardData data,
  ) {
    return _db.collection('combos').add({
      'title': title,
      'price': price,
      'imageURL': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'vendor': data.restaurantName,
    });
  }

  Future<void> deleteCombo(String comboId) {
    return _db.collection('combos').doc(comboId).delete();
  }

  Future<void> updateSeats({
    required int add2,
    required int add4,
    required int add8,
    required int add12,
  }) async {
    final user = _auth.currentUser!;
    final ref = _db.collection('rest').doc(user.uid);
    final current = await ref.get();
    final s = SeatStatusModel.fromMap(current.data()!);

    final new2 = s.two + add2;
    final new4 = s.four + add4;
    final new8 = s.eight + add8;
    final new12 = s.twelve + add12;
    final newAvail = new2 + new4 + new8 + new12;

    if (newAvail > s.total) {
      throw Exception('Over capacity');
    }

    final updated = SeatStatusModel(
      total: s.total,
      available: newAvail,
      two: new2,
      four: new4,
      eight: new8,
      twelve: new12,
    );

    await ref.update(updated.toMap());
  }
}
