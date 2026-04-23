import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _db;
  static const _collection = 'posts';

  PostRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // stream all posts sorted by date
  Stream<List<PostModel>> watchFeed() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PostModel.fromFirestore).toList());
  }

  Stream<List<PostModel>> watchUserPosts(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final posts = snap.docs.map(PostModel.fromFirestore).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  // create post
  Future<void> createPost({
    required String userId,
    required String username,
    required String content,
  }) async {
    try {
      await _db.collection(_collection).add({
        'userId': userId,
        'username': username,
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedBy': <String>[],
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
          'Failed to sync with Firebase server. Ensure Firestore Database is created in the console and security rules allow writes.',
        ),
      );
    } catch (e) {
      throw Exception('Create post failed: $e');
    }
  }

  // toggle like
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isLiked,
  }) async {
    final ref = _db.collection(_collection).doc(postId);
    if (isLiked) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  // delete post
  Future<void> deletePost(String postId) async {
    await _db.collection(_collection).doc(postId).delete();
  }
}
