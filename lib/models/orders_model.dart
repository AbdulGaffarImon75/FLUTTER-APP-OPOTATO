// lib/models/orders_model.dart

class OrderSummary {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImageUrl;
  final DateTime timestamp;
  final int total; // numeric total in currency units

  OrderSummary({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImageUrl,
    required this.timestamp,
    required this.total,
  });
}

class OrderItem {
  final String id;
  final String type; // 'offer' | 'combo'
  final String title;
  final String imageUrl;
  final String priceLabel; // e.g., "৳690"
  final int priceValue; // e.g., 690
  final int quantity;

  OrderItem({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.priceLabel,
    required this.priceValue,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m, String id) {
    // schema-tolerant reads
    final priceVal =
        (m['priceValue'] as num?)?.toInt() ??
        _parseInt(m['price'] ?? m['price_label'] ?? m['priceLabel']);
    return OrderItem(
      id: id,
      type: (m['type'] as String?) ?? '',
      title: (m['title'] as String?) ?? '',
      imageUrl: (m['imageUrl'] as String?) ?? (m['image_url'] as String?) ?? '',
      priceLabel:
          (m['priceLabel'] as String?) ??
          (m['price_label'] as String?) ??
          (m['price'] as String?) ??
          '',
      priceValue: priceVal,
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    final s = v.toString();
    final match = RegExp(r'\d+').allMatches(s).map((m) => m.group(0)!).join();
    return int.tryParse(match) ?? 0;
  }
}
