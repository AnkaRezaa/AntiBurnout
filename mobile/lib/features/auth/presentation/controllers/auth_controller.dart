import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../di/auth_providers.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restoreSession);
    return const AuthState.unknown();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> restoreSession() async {
    try {
      final user = await _repository.getCurrentUser();
      state = user == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _submit(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) {
    return _submit(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<bool> _submit(Future<AuthUser> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await action();
      state = AuthState.authenticated(user);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isSubmitting: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
