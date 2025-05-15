// models/billboard_model.dart

class BillboardModel {
  final String imageUrl;
  final String title;

  BillboardModel({required this.imageUrl, required this.title});

  factory BillboardModel.fromMap(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final price = data['price'] ?? '';
    return BillboardModel(
      imageUrl: data['imageURL'] ?? '',
      title: '$name\n$price',
    );
  }
}
