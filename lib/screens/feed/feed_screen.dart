import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/locale_keys.dart';
import '../../cubits/post/post_cubit.dart';
import '../../cubits/post/post_state.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostCubit>().watchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.feed.tr()),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.rocket_launch_rounded,
                color: Colors.white, size: 16),
          ),
        ),
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const AppLoader(size: 32);
          }

          if (state is PostError) {
            return _ErrorView(message: state.message);
          }

          if (state is PostLoaded) {
            if (state.posts.isEmpty) {
              return _EmptyView();
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<PostCubit>().watchFeed(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return _AnimatedPostItem(
                    key: ValueKey(state.posts[i].postId),
                    index: i,
                    child: PostCard(post: state.posts[i]),
                  );
                },
              ),
            );
          }

          return const AppLoader(size: 32);
        },
      ),
    );
  }
}

// fade + slide entry animation (Lecture 9 animation requirement)
class _AnimatedPostItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedPostItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedPostItem> createState() => _AnimatedPostItemState();
}

class _AnimatedPostItemState extends State<_AnimatedPostItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // stagger by index
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.noPosts.tr(),
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.likeFill),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.likeFill),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<PostCubit>().watchFeed(),
            child: Text(LocaleKeys.retry.tr()),
          ),
        ],
      ),
    );
  }
}
