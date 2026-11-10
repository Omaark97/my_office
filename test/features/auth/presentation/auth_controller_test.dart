import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/auth/domain/auth_failure.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';

import '../fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('authState starts signed out', () async {
    container.listen(authStateProvider, (_, _) {});

    expect(await container.read(authStateProvider.future), isNull);
  });

  test('signIn signs the user in', () async {
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'test.user@example.com', password: 'secret');

    expect(container.read(authControllerProvider).hasError, isFalse);
    expect(repository.currentUser?.email, 'test.user@example.com');
    expect(repository.signInAttempts.single.password, 'secret');
  });

  test('signIn is loading until the repository answers', () async {
    repository.holdSignIn = Completer<void>();
    final signIn = container
        .read(authControllerProvider.notifier)
        .signIn(email: 'test.user@example.com', password: 'secret');

    expect(container.read(authControllerProvider).isLoading, isTrue);

    repository.holdSignIn!.complete();
    await signIn;
    expect(container.read(authControllerProvider).isLoading, isFalse);
  });

  test('a wrong password ends in an AuthException error state', () async {
    repository.failNextSignInWith = AuthFailure.invalidCredentials;

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'test.user@example.com', password: 'wrong');

    final error = container.read(authControllerProvider).error;
    expect(error, isA<AuthException>());
    expect((error! as AuthException).failure, AuthFailure.invalidCredentials);
    expect(repository.currentUser, isNull);
  });

  test('a network failure is reported as such', () async {
    repository.failNextSignInWith = AuthFailure.network;

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'test.user@example.com', password: 'secret');

    final error = container.read(authControllerProvider).error;
    expect((error! as AuthException).failure, AuthFailure.network);
  });

  test('signOut signs the user out', () async {
    repository = FakeAuthRepository(signedInUser: testUser);
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    await container.read(authControllerProvider.notifier).signOut();

    expect(repository.signOutCalls, 1);
    expect(repository.currentUser, isNull);
  });

  test('authState follows sign-in and sign-out', () async {
    final states = <String?>[];
    container.listen(
      authStateProvider,
      (_, next) => states.add(next.value?.uid),
      fireImmediately: true,
    );
    await container.read(authStateProvider.future);

    final controller = container.read(authControllerProvider.notifier);
    await controller.signIn(email: 'test.user@example.com', password: 'secret');
    await Future<void>.delayed(Duration.zero);
    await controller.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(states.where((uid) => uid != null), isNotEmpty);
    expect(states.last, isNull);
  });
}
