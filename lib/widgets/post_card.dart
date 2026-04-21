import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/locale_keys.dart';
import '../cubits/post/post_cubit.dart';
import '../models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool showDelete;

  const PostCard({
    super.key,
    required this.post,
    this.showDelete = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.75,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _likeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // scale animation
    await _likeController.reverse();
    await _likeController.forward();

    final isLiked = widget.post.likedBy.contains(uid);
    if (mounted) {
      context.read<PostCubit>().toggleLike(
            postId: widget.post.postId,
            userId: uid,
            isLiked: isLiked,
          );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.deletePost.tr()),
        content: Text(LocaleKeys.deleteConfirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              LocaleKeys.deletePost.tr(),
              style: const TextStyle(color: AppColors.likeFill),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<PostCubit>().deletePost(widget.post.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = widget.post.likedBy.contains(uid);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    widget.post.username.isNotEmpty
                        ? widget.post.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(widget.post.createdAt),
                        style: TextStyle(
                          color: textSec,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showDelete)
                  IconButton(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: textSec,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // content
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 14),

            // like row
            Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: GestureDetector(
                    onTap: _handleLike,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? AppColors.likeFill.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLiked
                              ? AppColors.likeFill
                              : textSec.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 15,
                            color: isLiked ? AppColors.likeFill : textSec,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.post.likesCount}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isLiked ? AppColors.likeFill : textSec,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
