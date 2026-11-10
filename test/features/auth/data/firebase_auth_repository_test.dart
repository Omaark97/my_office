import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/auth/data/firebase_auth_repository.dart';
import 'package:my_office/features/auth/domain/auth_failure.dart';

void main() {
  test('wrong email or password all map to invalidCredentials', () {
    for (final code in [
      'invalid-credential',
      'wrong-password',
      'user-not-found',
    ]) {
      expect(
        authFailureFromFirebaseCode(code),
        AuthFailure.invalidCredentials,
        reason: code,
      );
    }
  });

  test('other known codes map to their failure', () {
    expect(
      authFailureFromFirebaseCode('invalid-email'),
      AuthFailure.invalidEmail,
    );
    expect(
      authFailureFromFirebaseCode('too-many-requests'),
      AuthFailure.tooManyAttempts,
    );
    expect(
      authFailureFromFirebaseCode('network-request-failed'),
      AuthFailure.network,
    );
    expect(
      authFailureFromFirebaseCode('user-disabled'),
      AuthFailure.userDisabled,
    );
  });

  test('an unknown code maps to unknown', () {
    expect(authFailureFromFirebaseCode('something-new'), AuthFailure.unknown);
  });
}
