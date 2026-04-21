import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import '../../services/local_storage_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;
  final LocalStorageService _storage;

  AuthCubit(this._authRepo, this._storage) : super(const AuthInitial());

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(const AuthLoading());
    try {
      final cred = await _authRepo.register(email: email, password: password);
      await _storage.saveUsername(username);
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      print('Unknown Error: $e');
      emit(const AuthError('Something went wrong. Try again.'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final cred = await _authRepo.login(email: email, password: password);
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(const AuthError('Something went wrong. Try again.'));
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    emit(const AuthUnauthenticated());
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/Password auth is disabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}
