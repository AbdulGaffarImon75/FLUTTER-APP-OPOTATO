import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String postedBy;
  final DateTime? timestamp;

  OfferModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.postedBy,
    required this.timestamp,
  });

  /// Construct from a Firestore DocumentSnapshot
  factory OfferModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      title: data['name'] ?? '',
      price: data['price']?.toString() ?? '',
      imageUrl: data['imageURL'] ?? '',
      postedBy: data['posted_by'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  /// Construct from a plain map that already contains an 'id' key
  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id']?.toString() ?? '',
      title: map['name'] ?? '',
      price: map['price']?.toString() ?? '',
      imageUrl: map['imageURL'] ?? '',
      postedBy: map['posted_by'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
