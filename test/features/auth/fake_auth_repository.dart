import 'dart:async';

import 'package:my_office/features/auth/data/auth_repository.dart';
import 'package:my_office/features/auth/domain/app_user.dart';
import 'package:my_office/features/auth/domain/auth_failure.dart';

const testUser = AppUser(uid: 'test-uid', email: 'test.user@example.com');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? signedInUser}) : _user = signedInUser;

  final _listeners = <StreamController<AppUser?>>[];
  AppUser? _user;

  AuthFailure? failNextSignInWith;
  Completer<void>? holdSignIn;
  final signInAttempts = <({String email, String password})>[];
  int signOutCalls = 0;

  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() {
    final controller = StreamController<AppUser?>();
    controller.onListen = () => controller.add(_user);
    controller.onCancel = () => _listeners.remove(controller);
    _listeners.add(controller);
    return controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInAttempts.add((email: email, password: password));
    if (holdSignIn != null) await holdSignIn!.future;
    final failure = failNextSignInWith;
    if (failure != null) {
      failNextSignInWith = null;
      throw AuthException(failure);
    }
    _setUser(AppUser(uid: testUser.uid, email: email));
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _setUser(null);
  }

  void _setUser(AppUser? user) {
    _user = user;
    for (final listener in List.of(_listeners)) {
      listener.add(user);
    }
  }
}
