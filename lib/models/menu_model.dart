class MenuModel {
  final String id;
  final String title;
  final String segment;
  final String price;
  final String imageURL;

  MenuModel({
    required this.id,
    required this.title,
    required this.segment,
    required this.price,
    required this.imageURL,
  });

  factory MenuModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuModel(
      id: id,
      title: data['title'] ?? '',
      segment: data['segment'] ?? '',
      price: data['price'] ?? '',
      imageURL: data['imageURL'] ?? '',
    );
  }
}
