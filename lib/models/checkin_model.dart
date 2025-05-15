// lib/models/checkin_model.dart

class CheckIn {
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final DateTime timestamp;

  CheckIn({
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.timestamp,
  });
}
