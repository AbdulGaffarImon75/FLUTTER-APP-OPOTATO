// models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String userType;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.userType,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImageUrl: data['profile_image_url'] ?? '',
      userType: data['user_type'] ?? 'unknown',
    );
  }
}
