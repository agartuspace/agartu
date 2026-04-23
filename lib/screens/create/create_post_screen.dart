import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/locale_keys.dart';
import '../../cubits/post/post_cubit.dart';
import '../../cubits/post/post_state.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_loader.dart';

class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _contentFocus = FocusNode();
  
  bool _isCreatingLocally = false;



  @override
  void initState() {
    super.initState();
    // focus on open (Lecture 7 FocusNode)
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_contentFocus));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isCreatingLocally) return;
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isCreatingLocally = true);
    _contentFocus.unfocus();

    final success = await context.read<PostCubit>().createPost(
          userId: uid,
          content: _contentController.text,
        );

    if (mounted) {
      setState(() => _isCreatingLocally = false);
      if (success) {
        _contentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post published!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onPostCreated?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSec =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.createPost.tr()),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<PostCubit, PostState>(
        listener: (context, state) {
          if (state is PostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.likeFill,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isCreating = _isCreatingLocally;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // user avatar row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.read<LocalStorageService>().username.isNotEmpty
                                ? context.read<LocalStorageService>().username
                                : (FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'User'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: TextStyle(color: textSec, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // text form
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                        decoration: InputDecoration(
                          hintText: LocaleKeys.postHint.tr(),
                          hintStyle: TextStyle(color: textSec),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.cardDark : Colors.white,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return LocaleKeys.postEmpty.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // character counter + post button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _contentController,
                    builder: (_, val, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${val.text.length} chars',
                            style: TextStyle(color: textSec, fontSize: 12),
                          ),
                          SizedBox(
                            width: 120,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: isCreating ? null : _submit,
                              icon: isCreating
                                  ? const AppLoader(size: 16)
                                  : const Icon(Icons.send_rounded, size: 16),
                              label: Text(LocaleKeys.post.tr()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
