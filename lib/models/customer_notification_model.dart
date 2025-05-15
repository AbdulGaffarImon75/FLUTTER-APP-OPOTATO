class CustomerNotification {
  final String name;
  final String price;
  final String imageUrl;
  final String postedBy;
  final String profileImageUrl;
  final DateTime? timestamp;

  CustomerNotification({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.postedBy,
    required this.profileImageUrl,
    this.timestamp,
  });
}
