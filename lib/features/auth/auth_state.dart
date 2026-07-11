enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isSubmitting = false,
    this.isSendingCode = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isSubmitting;
  final bool isSendingCode;
  final String? errorMessage;
}
