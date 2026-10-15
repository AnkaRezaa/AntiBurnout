import '../../domain/entities/auth_user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isSubmitting = false,
    this.justRegistered = false,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.authenticated(AuthUser user, {bool justRegistered = false})
    : this(
        status: AuthStatus.authenticated,
        user: user,
        justRegistered: justRegistered,
      );

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isSubmitting;
  final bool justRegistered;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? isSubmitting,
    bool? justRegistered,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      justRegistered: justRegistered ?? this.justRegistered,
    );
  }
}
