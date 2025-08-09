// lib/models/cart_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id; // Firestore doc id
  final String itemId; // source id (offer/combo) if you have it
  final String type; // 'offer' | 'combo'
  final String restaurantId;
  final String restaurantName;
  final String title;
  final String imageUrl;
  final String priceLabel; // original price text (e.g., "৳290")
  final int priceValue; // numeric price (smallest unit)
  final int quantity;
  final DateTime timestamp;

  CartItem({
    required this.id,
    required this.itemId,
    required this.type,
    required this.restaurantId,
    required this.restaurantName,
    required this.title,
    required this.imageUrl,
    required this.priceLabel,
    required this.priceValue,
    required this.quantity,
    required this.timestamp,
  });

  factory CartItem.fromMap(String id, Map<String, dynamic> m) {
    return CartItem(
      id: id,
      itemId: m['item_id'] ?? '',
      type: m['type'] ?? 'offer',
      restaurantId: m['restaurant_id'] ?? '',
      restaurantName: m['restaurant_name'] ?? '',
      title: m['title'] ?? '',
      imageUrl: m['image_url'] ?? '',
      priceLabel: m['price_label'] ?? '',
      priceValue: (m['price_value'] ?? 0) as int,
      quantity: (m['quantity'] ?? 1) as int,
      timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'item_id': itemId,
    'type': type,
    'restaurant_id': restaurantId,
    'restaurant_name': restaurantName,
    'title': title,
    'image_url': imageUrl,
    'price_label': priceLabel,
    'price_value': priceValue,
    'quantity': quantity,
    'timestamp': FieldValue.serverTimestamp(),
  };

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    itemId: itemId,
    type: type,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    title: title,
    imageUrl: imageUrl,
    priceLabel: priceLabel,
    priceValue: priceValue,
    quantity: quantity ?? this.quantity,
    timestamp: timestamp,
  );
}
