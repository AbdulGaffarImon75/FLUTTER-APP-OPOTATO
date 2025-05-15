// controllers/home_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cuisine_model.dart';
import '../models/combo_model.dart';
import '../models/offer_model.dart';
import '../models/restaurant_model.dart';
import '../models/billboard_model.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CuisineModel>> fetchCuisines() async {
    final snap = await _firestore.collection('cuisines').get();
    return snap.docs.map((doc) => CuisineModel.fromMap(doc.data())).toList();
  }

  Future<List<ComboModel>> fetchCombos() async {
    final snap =
        await _firestore
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();
    return snap.docs.map((doc) => ComboModel.fromMap(doc.data())).toList();
  }

  Future<List<OfferModel>> fetchOffers() async {
    final snap = await _firestore.collection('offers').get();
    return snap.docs.map((doc) => OfferModel.fromMap(doc.data())).toList();
  }

  Future<List<RestaurantModel>> fetchRestaurants() async {
    final snap =
        await _firestore
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();
    return snap.docs.map((doc) => RestaurantModel.fromMap(doc.data())).toList();
  }

  Future<BillboardModel?> fetchLatestBillboard() async {
    final snap =
        await _firestore
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      return BillboardModel.fromMap(snap.docs.first.data());
    }
    return null;
  }
}
