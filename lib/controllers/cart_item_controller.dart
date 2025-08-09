// lib/controllers/cart_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';
import '../models/offer_model.dart';
import '../models/combo_model.dart';

class CartController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _itemsCol {
    if (_uid == null) {
      throw Exception('Not signed in');
    }
    return _db.collection('carts').doc(_uid).collection('items');
  }

  /// Parse the first number found in a price string.
  /// "৳300, 890, 1480" -> 300
  int _parsePriceToInt(String label) {
    final m = RegExp(r'\d+').firstMatch(label)?.group(0);
    return int.tryParse(m ?? '0') ?? 0;
  }

  // ---------- basic fetch ----------

  Future<List<CartItem>> fetchCart() async {
    if (_uid == null) return [];
    final snap = await _itemsCol.orderBy('timestamp', descending: true).get();
    return snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList();
  }

  // ---------- add helpers ----------

  /// Add a specific item/variant to the cart.
  /// We "merge" quantities by (type, restaurant, title, price_value).
  Future<void> addItem({
    required String type, // 'offer' | 'combo'
    required String restaurantId,
    required String restaurantName,
    required String title,
    required String imageUrl,
    required String priceLabel,
    required int priceValue,
    String sourceId = '', // optional Offer/Combo ID
  }) async {
    if (_uid == null) return;

    final existing =
        await _itemsCol
            .where('type', isEqualTo: type)
            .where('restaurant_id', isEqualTo: restaurantId)
            .where('title', isEqualTo: title)
            .where('price_value', isEqualTo: priceValue)
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await _itemsCol.add({
        'item_id': sourceId,
        'type': type,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'title': title,
        'image_url': imageUrl,
        'price_label': priceLabel,
        'price_value': priceValue,
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Convenience for single‑price offer strings.
  Future<void> addOffer({
    required OfferModel offer,
    required String restaurantId,
    required String restaurantName,
    String offerId = '',
  }) async {
    final priceVal = _parsePriceToInt(offer.price);
    await addItem(
      type: 'offer',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      title: offer.title,
      imageUrl: offer.imageUrl,
      priceLabel: offer.price,
      priceValue: priceVal,
      sourceId: offerId,
    );
  }

  /// Convenience for single‑price combo strings.
  Future<void> addCombo({
    required ComboModel combo,
    required String restaurantId,
    required String restaurantName,
    String comboId = '',
  }) async {
    final priceVal = _parsePriceToInt(combo.price);
    await addItem(
      type: 'combo',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      title: combo.title,
      imageUrl: combo.imageUrl,
      priceLabel: combo.price,
      priceValue: priceVal,
      sourceId: comboId,
    );
  }

  // ---------- quantity & clearing ----------

  Future<void> inc(String id) async {
    await _itemsCol.doc(id).update({'quantity': FieldValue.increment(1)});
  }

  Future<void> dec(String id) async {
    final doc = await _itemsCol.doc(id).get();
    final q = (doc.data()?['quantity'] ?? 1) as int;
    if (q <= 1) {
      await _itemsCol.doc(id).delete();
    } else {
      await _itemsCol.doc(id).update({'quantity': q - 1});
    }
  }

  Future<void> remove(String id) async {
    await _itemsCol.doc(id).delete();
  }

  Future<void> clearAll() async {
    if (_uid == null) return;
    final snap = await _itemsCol.get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }

  /// Remove any items not from [restaurantId].
  Future<void> clearForOtherRestaurants(String restaurantId) async {
    if (_uid == null) return;
    final snap =
        await _itemsCol
            .where('restaurant_id', isNotEqualTo: restaurantId)
            .get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }

  // ---------- live badge & single‑restaurant guard ----------

  /// Live cart count (sum of quantities).
  Stream<int> cartCountStream() {
    if (_uid == null) return const Stream<int>.empty();
    return _itemsCol.snapshots().map(
      (snap) => snap.docs.fold<int>(
        0,
        (sum, d) => sum + ((d.data()['quantity'] ?? 1) as int),
      ),
    );
  }

  /// True if cart contains any items from restaurants other than [restaurantId].
  Future<bool> hasItemsFromOtherRestaurants(String restaurantId) async {
    if (_uid == null) return false;
    final snap = await _itemsCol.get();
    final ids = <String>{};
    for (final d in snap.docs) {
      final rid = (d.data()['restaurant_id'] ?? '') as String;
      if (rid.isNotEmpty) ids.add(rid);
    }
    if (ids.isEmpty) return false;
    return !(ids.length == 1 && ids.contains(restaurantId));
  }
}
