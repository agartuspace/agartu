import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../constants/locale_keys.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_loader.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.register(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AuthCubit(
        ctx.read<AuthRepository>(),
        ctx.read<LocalStorageService>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          elevation: 0,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.likeFill,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            final isLoading = state is AuthLoading;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textSec =
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // header
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocaleKeys.register.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join Agartu',
                          style: TextStyle(color: textSec, fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // username
                          TextFormField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_emailFocus),
                            decoration: InputDecoration(
                              labelText: LocaleKeys.username.tr(),
                              prefixIcon:
                                  const Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return LocaleKeys.fieldRequired.tr();
                              }
                              if (v.trim().length < 2) {
                                return 'At least 2 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // email
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocus),
                            decoration: InputDecoration(
                              labelText: LocaleKeys.email.tr(),
                              prefixIcon:
                                  const Icon(Icons.email_outlined, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return LocaleKeys.fieldRequired.tr();
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                                return LocaleKeys.emailInvalid.tr();
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // password
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(cubit),
                            decoration: InputDecoration(
                              labelText: LocaleKeys.password.tr(),
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return LocaleKeys.fieldRequired.tr();
                              }
                              if (v.length < 6) {
                                return LocaleKeys.passwordShort.tr();
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // register button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(cubit),
                        child: isLoading
                            ? const AppLoader(size: 20)
                            : Text(LocaleKeys.register.tr()),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // go to login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.haveAccount.tr(),
                          style: TextStyle(color: textSec),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(LocaleKeys.login.tr()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
