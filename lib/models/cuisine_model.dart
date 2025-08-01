// models/cuisine_model.dart

class CuisineModel {
  final String label;
  final String imageUrl;

  CuisineModel({required this.label, required this.imageUrl});

  factory CuisineModel.fromMap(Map<String, dynamic> data) {
    return CuisineModel(
      label: data['label'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
