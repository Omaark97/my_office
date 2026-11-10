import '../domain/auth_failure.dart';

String authErrorMessage(Object error) {
  if (error is! AuthException) return 'Could not sign in. Please try again.';
  switch (error.failure) {
    case AuthFailure.invalidCredentials:
      return 'Wrong email or password.';
    case AuthFailure.invalidEmail:
      return 'That email address is not valid.';
    case AuthFailure.tooManyAttempts:
      return 'Too many attempts. Try again in a few minutes.';
    case AuthFailure.network:
      return 'No internet connection. Check your network and try again.';
    case AuthFailure.userDisabled:
      return 'This account has been disabled.';
    case AuthFailure.unknown:
      return 'Could not sign in. Please try again.';
  }
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!email.contains('@')) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter your password';
  return null;
}
