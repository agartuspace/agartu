import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/post_repository.dart';
import '../../services/local_storage_service.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repo;
  final LocalStorageService _storage;

  StreamSubscription? _feedSub;
  StreamSubscription? _userSub;

  PostCubit(this._repo, this._storage) : super(const PostInitial());

  // watch global feed
  void watchFeed() {
    emit(const PostLoading());
    _feedSub?.cancel();
    _feedSub = _repo.watchFeed().listen(
          (posts) => emit(PostLoaded(posts)),
          onError: (e) => emit(PostError(e.toString())),
        );
  }

  // watch user posts
  void watchUserPosts(String userId) {
    emit(const PostLoading());
    _userSub?.cancel();
    _userSub = _repo.watchUserPosts(userId).listen(
          (posts) => emit(PostLoaded(posts)),
          onError: (e) => emit(PostError(e.toString())),
        );
  }

  // create post
  Future<bool> createPost({
    required String userId,
    required String content,
  }) async {
    final previousState = state;
    emit(const PostCreating());
    try {
      final username =
          _storage.username.isNotEmpty ? _storage.username : 'User';
      await _repo.createPost(
        userId: userId,
        username: username,
        content: content,
      );
      return true;
    } catch (e) {
      emit(PostError(e.toString()));
      emit(previousState);
      return false;
    }
  }

  // toggle like
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isLiked,
  }) async {
    try {
      await _repo.toggleLike(
        postId: postId,
        userId: userId,
        isLiked: isLiked,
      );
    } catch (_) {}
  }

  // delete post
  Future<void> deletePost(String postId) async {
    try {
      await _repo.deletePost(postId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _feedSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
