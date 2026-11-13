import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_office/app/app.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import 'features/auth/fake_auth_repository.dart';

void main() {
  testWidgets('App starts and shows the home screen when signed in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(signedInUser: testUser),
          ),
          transactionRepositoryProvider.overrideWithValue(
            InMemoryTransactionRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'My Office');

    expect(find.text('Home'), findsOneWidget);

    expect(find.text('Test User 2'), findsOneWidget);
  });
}
