// lib/controllers/orders_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/orders_model.dart';

class OrdersController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create an order from the current cart, then clear the cart.
  /// Returns the newly created orderId or null if cart is empty.
  Future<String?> placeOrderFromCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final cartItemsRef = _db
        .collection('carts')
        .doc(user.uid)
        .collection('items');
    final cartSnap = await cartItemsRef.get();
    if (cartSnap.docs.isEmpty) return null;

    // Derive restaurant from first item (your app enforces single-restaurant cart)
    final first = cartSnap.docs.first.data();
    final restaurantId =
        (first['restaurantId'] as String?) ??
        (first['restaurant_id'] as String?) ??
        '';
    final restaurantName =
        (first['restaurantName'] as String?) ??
        (first['restaurant_name'] as String?) ??
        'Restaurant';

    // Compute total from numeric priceValue (fallback: parse priceLabel)
    int total = 0;
    for (final d in cartSnap.docs) {
      final m = d.data();
      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      final pv =
          (m['priceValue'] as num?)?.toInt() ??
          _parseInt(m['price'] ?? m['price_label'] ?? m['priceLabel']);
      total += qty * pv;
    }

    // Create order summary
    final orderDoc = await _db.collection('orders').add({
      'user_id': user.uid,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName, // not trusted for UI; we enrich later
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Write items into subcollection
    final itemsRef = orderDoc.collection('items');
    for (final d in cartSnap.docs) {
      final m = d.data();
      await itemsRef.add({
        'type': m['type'] ?? '',
        'title': m['title'] ?? '',
        'imageUrl': m['imageUrl'] ?? m['image_url'] ?? '',
        'priceLabel': m['priceLabel'] ?? m['price_label'] ?? m['price'] ?? '',
        'priceValue':
            (m['priceValue'] as num?)?.toInt() ??
            _parseInt(m['price'] ?? m['price_label'] ?? m['priceLabel']),
        'quantity': (m['quantity'] as num?)?.toInt() ?? 1,
      });
    }

    // Clear cart
    for (final d in cartSnap.docs) {
      await cartItemsRef.doc(d.id).delete();
    }

    return orderDoc.id;
  }

  /// Fetch all orders for current user (newest first) and
  /// ENRICH each with restaurant name & image just like check-ins do.
  Future<List<OrderSummary>> fetchMyOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Requires a composite index: user_id ASC, timestamp DESC
    final snap =
        await _db
            .collection('orders')
            .where('user_id', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    final List<OrderSummary> list = [];
    for (final doc in snap.docs) {
      final data = doc.data();
      final rid = (data['restaurant_id'] as String?) ?? '';
      final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      final total = (data['total'] as num?)?.toInt() ?? 0;

      // Look up restaurant info (check-in style)
      String name = data['restaurant_name'] ?? 'Restaurant';
      String imageUrl = '';
      if (rid.isNotEmpty) {
        final restDoc = await _db.collection('users').doc(rid).get();
        final rest = restDoc.data() ?? {};
        name = rest['name'] ?? name;
        imageUrl = rest['profile_image_url'] ?? '';
      }

      list.add(
        OrderSummary(
          id: doc.id,
          restaurantId: rid,
          restaurantName: name,
          restaurantImageUrl: imageUrl,
          timestamp: ts,
          total: total,
        ),
      );
    }
    return list;
  }

  /// Items for a given order id.
  Future<List<OrderItem>> fetchOrderItems(String orderId) async {
    final items =
        await _db.collection('orders').doc(orderId).collection('items').get();
    return items.docs.map((d) => OrderItem.fromMap(d.data(), d.id)).toList();
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    final s = v.toString();
    final match = RegExp(r'\d+').allMatches(s).map((m) => m.group(0)!).join();
    return int.tryParse(match) ?? 0;
  }
}
