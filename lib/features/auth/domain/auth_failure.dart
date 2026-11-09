enum AuthFailure {
  invalidCredentials,
  invalidEmail,
  tooManyAttempts,
  network,
  userDisabled,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}
