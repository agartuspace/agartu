import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/locale_keys.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/post/post_cubit.dart';
import '../../cubits/post/post_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/post_repository.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/post_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  bool _editingName = false;

  late PostCubit _profilePostCubit;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _profilePostCubit = PostCubit(
      context.read<PostRepository>(),
      context.read<LocalStorageService>(),
    );
    if (user != null) {
      _profilePostCubit.watchUserPosts(user.uid);
    }
    _usernameController.text = context.read<LocalStorageService>().username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _profilePostCubit.close();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    final name = _usernameController.text.trim();
    if (name.isEmpty) return;
    await context.read<LocalStorageService>().saveUsername(name);
    setState(() => _editingName = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username updated'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.logout.tr()),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LocaleKeys.logout.tr(),
                style: const TextStyle(color: AppColors.likeFill)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // pushAndRemoveUntil — Lecture 6 navigation pattern
      await context.read<AuthCubit>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSec =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.cardDark : Colors.white;
    final storage = context.read<LocalStorageService>();
    final themeMode = context.watch<ThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.profile.tr()),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── profile card ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    storage.username.isNotEmpty
                        ? storage.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // username field
                if (_editingName) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.username.tr(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _saveUsername,
                        child: Text(LocaleKeys.save.tr()),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    storage.username.isNotEmpty ? storage.username : 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(user?.email ?? '', style: TextStyle(color: textSec)),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => setState(() => _editingName = true),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: Text(LocaleKeys.editProfile.tr()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── settings card ───────────────────────────────────────────────
          _SectionCard(
            isDark: isDark,
            children: [
              // theme toggle
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                label: LocaleKeys.theme.tr(),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(10),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(LocaleKeys.lightTheme.tr()),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(LocaleKeys.darkTheme.tr()),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: const Text('System'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode == ThemeMode.light) {
                      context.read<ThemeCubit>().setLight();
                    } else if (mode == ThemeMode.dark) {
                      context.read<ThemeCubit>().setDark();
                    } else {
                      context.read<ThemeCubit>().setSystem();
                    }
                  },
                ),
              ),

              Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),

              // language selector
              _SettingsTile(
                icon: Icons.language_outlined,
                label: LocaleKeys.language.tr(),
                trailing: DropdownButton<String>(
                  value: context.locale.languageCode,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(10),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                  ],
                  onChanged: (lang) {
                    if (lang != null) {
                      context.read<LocaleCubit>().changeLocale(context, lang);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── my posts ────────────────────────────────────────────────────
          Text(
            LocaleKeys.myPosts.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          BlocBuilder<PostCubit, PostState>(
            bloc: _profilePostCubit,
            builder: (context, state) {
              if (state is PostLoading) {
                return const AppLoader(size: 28);
              }
              if (state is PostError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Failed to load posts: ${state.message}',
                      style: const TextStyle(color: AppColors.likeFill),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (state is PostLoaded) {
                if (state.posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        LocaleKeys.noPosts.tr(),
                        style: TextStyle(color: textSec),
                      ),
                    ),
                  );
                }
                return Column(
                  children: state.posts
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BlocProvider.value(
                              value: context.read<PostCubit>(),
                              child: PostCard(post: p, showDelete: true),
                            ),
                          ))
                      .toList(),
                );
              }
              return const SizedBox();
            },
          ),

          const SizedBox(height: 16),

          // ── logout ──────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded,
                size: 18, color: AppColors.likeFill),
            label: Text(
              LocaleKeys.logout.tr(),
              style: const TextStyle(color: AppColors.likeFill),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.likeFill),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SectionCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          trailing,
        ],
      ),
    );
  }
}
