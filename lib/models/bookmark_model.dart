// lib/models/bookmark_model.dart

class BookmarkModel {
  final String id;
  final String title;
  final String price;
  final String vendor;
  final String imageUrl;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.price,
    required this.vendor,
    required this.imageUrl,
  });
}
