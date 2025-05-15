// models/restaurant_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantAdminModel {
  final String uid;
  final String name;
  final String imageUrl;

  RestaurantAdminModel({
    required this.uid,
    required this.name,
    required this.imageUrl,
  });

  /// Construct from a Firestore document snapshot
  factory RestaurantAdminModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantAdminModel(
      uid: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['profile_image_url'] ?? '',
    );
  }
}
