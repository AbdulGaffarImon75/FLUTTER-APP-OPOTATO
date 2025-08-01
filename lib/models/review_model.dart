import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final DateTime? timestamp;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    this.timestamp,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] as String?,
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
