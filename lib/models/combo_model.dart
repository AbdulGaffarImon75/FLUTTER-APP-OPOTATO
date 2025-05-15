import 'package:cloud_firestore/cloud_firestore.dart';

class ComboModel {
  final String id;
  final String title;
  final String vendor;
  final String price;
  final String imageUrl;
  final DateTime? timestamp;

  ComboModel({
    required this.id,
    required this.title,
    required this.vendor,
    required this.price,
    required this.imageUrl,
    required this.timestamp,
  });

  /// Build from a Firestore DocumentSnapshot
  factory ComboModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawPrice = data['price'] ?? '';
    final formattedPrice =
        rawPrice.toString().contains('৳') ? rawPrice.toString() : '৳$rawPrice';

    return ComboModel(
      id: doc.id,
      title: data['title'] ?? '',
      vendor: data['vendor'] ?? '',
      imageUrl: data['imageURL'] ?? '',
      price: formattedPrice,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  /// Build from a plain Map (e.g. your own serialization)
  factory ComboModel.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['price'] ?? '';
    final formattedPrice =
        rawPrice.toString().contains('৳') ? rawPrice.toString() : '৳$rawPrice';

    return ComboModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      vendor: map['vendor'] ?? '',
      imageUrl: map['imageURL'] ?? '',
      price: formattedPrice,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
