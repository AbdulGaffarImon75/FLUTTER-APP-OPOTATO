// lib/models/restaurant_follow_model.dart

class RestaurantFollow {
  final String uid;
  final String name;
  final String imageUrl;
  final bool isFollowing;

  RestaurantFollow({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.isFollowing,
  });
}
