import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/app/app.dart';
import 'package:my_office/app/router.dart';
import 'package:my_office/app/routes.dart';
import 'package:my_office/features/auth/domain/app_user.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../features/auth/fake_auth_repository.dart';
import '../test_helpers.dart';

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository auth,
) async {
  useIPhoneScreen(tester);
  final container = ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      transactionRepositoryProvider.overrideWithValue(
        InMemoryTransactionRepository(),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('authRedirect', () {
    const user = AsyncData<AppUser?>(testUser);
    const signedOut = AsyncData<AppUser?>(null);
    const checking = AsyncLoading<AppUser?>();

    test('shows the loading screen while the auth state is unknown', () {
      expect(authRedirect(checking, AppRoutes.home), AppRoutes.loading);
      expect(authRedirect(checking, AppRoutes.loading), isNull);
    });

    test('sends a signed-out user to login from anywhere', () {
      expect(authRedirect(signedOut, AppRoutes.home), AppRoutes.login);
      expect(
        authRedirect(signedOut, AppRoutes.transaction('test-1')),
        AppRoutes.login,
      );
      expect(authRedirect(signedOut, AppRoutes.loading), AppRoutes.login);
      expect(authRedirect(signedOut, AppRoutes.login), isNull);
    });

    test('sends a signed-in user away from login and loading', () {
      expect(authRedirect(user, AppRoutes.login), AppRoutes.home);
      expect(authRedirect(user, AppRoutes.loading), AppRoutes.home);
    });

    test('lets a signed-in user open any app screen', () {
      expect(authRedirect(user, AppRoutes.home), isNull);
      expect(authRedirect(user, AppRoutes.transaction('test-1')), isNull);
    });

    test('treats an auth error as signed out', () {
      final error = AsyncError<AppUser?>(Exception('broken'), StackTrace.empty);

      expect(authRedirect(error, AppRoutes.home), AppRoutes.login);
    });
  });

  testWidgets('a signed-out user sees the login screen', (tester) async {
    await _pumpApp(tester, FakeAuthRepository());

    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    expect(find.text('Quick Access'), findsNothing);
  });

  testWidgets('signing in opens the home screen', (tester) async {
    await _pumpApp(tester, FakeAuthRepository());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test.user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Test User 1'), findsOneWidget);
  });

  testWidgets('the sign-out button returns to the login screen', (
    tester,
  ) async {
    final auth = FakeAuthRepository(signedInUser: testUser);
    await _pumpApp(tester, auth);
    expect(find.text('Quick Access'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 1);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    expect(find.text('Quick Access'), findsNothing);
  });

  testWidgets('opening a transaction while signed out shows login instead', (
    tester,
  ) async {
    final container = await _pumpApp(tester, FakeAuthRepository());

    container.read(routerProvider).go(AppRoutes.transaction('test-1'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    expect(find.text('Transaction Details'), findsNothing);
  });
}
