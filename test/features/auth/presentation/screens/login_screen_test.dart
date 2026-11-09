import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/auth/domain/auth_failure.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/auth/presentation/screens/login_screen.dart';

import '../../../../test_helpers.dart';
import '../../fake_auth_repository.dart';

Future<FakeAuthRepository> _pumpLogin(WidgetTester tester) async {
  useIPhoneScreen(tester);
  final repository = FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  return repository;
}

Finder get _emailField => find.widgetWithText(TextFormField, 'Email');
Finder get _passwordField => find.widgetWithText(TextFormField, 'Password');
Finder get _signInButton => find.widgetWithText(ElevatedButton, 'Sign in');

Future<void> _fillIn(
  WidgetTester tester, {
  String email = 'test.user@example.com',
  String password = 'secret',
}) async {
  await tester.enterText(_emailField, email);
  await tester.enterText(_passwordField, password);
}

void main() {
  testWidgets('shows the email and password fields and the button', (
    tester,
  ) async {
    await _pumpLogin(tester);

    expect(find.text('My Office'), findsOneWidget);
    expect(_emailField, findsOneWidget);
    expect(_passwordField, findsOneWidget);
    expect(_signInButton, findsOneWidget);
  });

  testWidgets('empty fields show validation messages and do not sign in', (
    tester,
  ) async {
    final repository = await _pumpLogin(tester);

    await tester.tap(_signInButton);
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(repository.signInAttempts, isEmpty);
  });

  testWidgets('an email without "@" is rejected', (tester) async {
    final repository = await _pumpLogin(tester);

    await _fillIn(tester, email: 'not-an-email');
    await tester.tap(_signInButton);
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repository.signInAttempts, isEmpty);
  });

  testWidgets('valid input signs in with a trimmed email', (tester) async {
    final repository = await _pumpLogin(tester);

    await _fillIn(tester, email: '  test.user@example.com  ');
    await tester.tap(_signInButton);
    await tester.pumpAndSettle();

    expect(repository.signInAttempts.single.email, 'test.user@example.com');
    expect(repository.signInAttempts.single.password, 'secret');
    expect(repository.currentUser, isNotNull);
  });

  testWidgets('a wrong password shows a friendly message', (tester) async {
    final repository = await _pumpLogin(tester);
    repository.failNextSignInWith = AuthFailure.invalidCredentials;

    await _fillIn(tester, password: 'wrong');
    await tester.tap(_signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Wrong email or password.'), findsOneWidget);
  });

  testWidgets('a network failure shows a network message', (tester) async {
    final repository = await _pumpLogin(tester);
    repository.failNextSignInWith = AuthFailure.network;

    await _fillIn(tester);
    await tester.tap(_signInButton);
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('the button shows a spinner and is disabled while signing in', (
    tester,
  ) async {
    final repository = await _pumpLogin(tester);
    repository.holdSignIn = Completer<void>();

    await _fillIn(tester);
    await tester.tap(_signInButton);
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);

    repository.holdSignIn!.complete();
    await tester.pumpAndSettle();
  });
}
