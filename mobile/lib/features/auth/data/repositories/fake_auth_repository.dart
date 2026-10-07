import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? _currentUser;
  final Map<String, _StoredAccount> _accounts = {};

  @override
  Future<AuthUser?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _currentUser;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw Exception('Email atau kata sandi tidak sesuai.');
    }
    _currentUser = account.user;
    return account.user;
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw Exception('Email sudah terdaftar.');
    }
    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: key,
      name: name.trim(),
    );
    _accounts[key] = _StoredAccount(user: user, password: password);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}

class _StoredAccount {
  const _StoredAccount({required this.user, required this.password});

  final AuthUser user;
  final String password;
}
