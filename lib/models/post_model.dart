import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final List<String> likedBy;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.likedBy,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? 'User',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': likesCount,
      'likedBy': likedBy,
    };
  }

  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    List<String>? likedBy,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
