import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/locale_keys.dart';
import '../../cubits/api/api_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/post/post_cubit.dart';
import '../../repositories/api_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/post_repository.dart';
import '../../services/local_storage_service.dart';
import '../create/create_post_screen.dart';
import '../explore/explore_screen.dart';
import '../feed/feed_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    FeedScreen(),
    CreatePostScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<PostRepository>(create: (_) => PostRepository()),
        RepositoryProvider<ApiRepository>(create: (_) => ApiRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (ctx) => AuthCubit(
              ctx.read<AuthRepository>(),
              ctx.read<LocalStorageService>(),
            ),
          ),
          BlocProvider<PostCubit>(
            create: (ctx) => PostCubit(
              ctx.read<PostRepository>(),
              ctx.read<LocalStorageService>(),
            ),
          ),
          BlocProvider<ApiCubit>(
            create: (ctx) => ApiCubit(ctx.read<ApiRepository>()),
          ),
        ],
        child: Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, anim) {
              // page transition animation
              final slideAnim = Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: slideAnim, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: LocaleKeys.feed.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle_rounded),
            label: LocaleKeys.create.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore_rounded),
            label: LocaleKeys.explore.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person_rounded),
            label: LocaleKeys.profile.tr(),
          ),
        ],
      ),
    );
  }
}
