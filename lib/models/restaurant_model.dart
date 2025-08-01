// models/restaurant_model.dart

class RestaurantModel {
  final String name;
  final String imageUrl;

  RestaurantModel({required this.name, required this.imageUrl});

  /// Only takes the Firestore field map, no ID.
  factory RestaurantModel.fromMap(Map<String, dynamic> data) {
    return RestaurantModel(
      name: data['name'] ?? '',
      imageUrl: data['profile_image_url'] ?? '',
    );
  }
}
