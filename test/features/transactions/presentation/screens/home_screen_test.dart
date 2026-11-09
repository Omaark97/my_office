import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/data/transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_document.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/presentation/screens/home_screen.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../../test_helpers.dart';

/// A repository whose loading always fails, to test the error message.
class _FailingRepository implements TransactionRepository {
  @override
  Future<List<Transaction>> getTransactions() async =>
      throw Exception('offline');

  @override
  Future<List<TransactionDocument>> getDocuments(String transactionId) async =>
      const [];

  @override
  Future<void> updateStatus(
    String id, {
    required TransactionStatus status,
    DateTime? dateCompleted,
    required DateTime updatedAt,
  }) async {}
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required TransactionRepository repository,
}) async {
  useIPhoneScreen(tester);
  await tester.pumpWidget(
    ProviderScope(
      // Don't retry failed loads in tests; fail at once.
      retry: (retryCount, error) => null,
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: HomeScreen(title: 'Home')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows every test transaction with its status line', (
    tester,
  ) async {
    await _pumpHome(tester, repository: InMemoryTransactionRepository());

    expect(find.text('Test User 1'), findsOneWidget);
    expect(find.text('Test User 2'), findsOneWidget);
    expect(find.text('Test User 3'), findsOneWidget);
    expect(find.text('Test User 4'), findsOneWidget);
    expect(find.text('Test User 5'), findsOneWidget);

    expect(find.text('Completed on 2024-05-15'), findsOneWidget);
    expect(find.text('Pending since 2024-06-01'), findsOneWidget);
    expect(find.text('Completed on 2024-04-20'), findsOneWidget);
    expect(find.text('Pending since 2024-05-30'), findsNWidgets(2));
  });

  testWidgets('shows the icon of each transaction type', (tester) async {
    await _pumpHome(tester, repository: InMemoryTransactionRepository());

    // Only look inside the transaction rows, not the Quick Access cards.
    Finder rowIcon(IconData icon) =>
        find.descendant(of: find.byType(ListTile), matching: find.byIcon(icon));

    // Test User 1 and 5 are taxi registrations, Test User 2 a license
    // renewal, Test User 3 a lien release, Test User 4 an ownership transfer.
    expect(rowIcon(Icons.local_taxi), findsNWidgets(2));
    expect(rowIcon(Icons.card_membership), findsOneWidget);
    expect(rowIcon(Icons.lock_open), findsOneWidget);
    expect(rowIcon(Icons.swap_horiz), findsOneWidget);
  });

  testWidgets('shows completed and pending status icons', (tester) async {
    await _pumpHome(tester, repository: InMemoryTransactionRepository());

    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.byIcon(Icons.hourglass_empty), findsNWidgets(3));
  });

  testWidgets('keeps the Quick Access cards and the search bar', (
    tester,
  ) async {
    await _pumpHome(tester, repository: InMemoryTransactionRepository());

    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Identification Documents'), findsOneWidget);
    expect(find.text('Search transactions...'), findsOneWidget);
  });

  testWidgets('shows a message when transactions cannot be loaded', (
    tester,
  ) async {
    await _pumpHome(tester, repository: _FailingRepository());

    expect(find.text('Could not load transactions'), findsOneWidget);
  });
}
