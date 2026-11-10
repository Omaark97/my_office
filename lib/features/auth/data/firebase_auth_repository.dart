import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';
import '../domain/auth_failure.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : AppUser(uid: user.uid, email: user.email),
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(authFailureFromFirebaseCode(error.code));
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

AuthFailure authFailureFromFirebaseCode(String code) {
  switch (code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return AuthFailure.invalidCredentials;
    case 'invalid-email':
      return AuthFailure.invalidEmail;
    case 'too-many-requests':
      return AuthFailure.tooManyAttempts;
    case 'network-request-failed':
      return AuthFailure.network;
    case 'user-disabled':
      return AuthFailure.userDisabled;
    default:
      return AuthFailure.unknown;
  }
}
