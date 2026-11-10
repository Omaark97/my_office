import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/data/transaction_repository.dart';
import 'package:my_office/features/transactions/domain/archive_access_denied_exception.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_document.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/presentation/load_error_message.dart';
import 'package:my_office/features/transactions/presentation/screens/home_screen.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../../test_helpers.dart';

class _FailingRepository implements TransactionRepository {
  _FailingRepository(this.error);

  final Object error;

  @override
  Future<List<Transaction>> getTransactions() async => throw error;

  @override
  Future<List<TransactionDocument>> getDocuments(String transactionId) async =>
      const [];

  @override
  Future<void> updateStatus(String id, TransactionStatus status) async {}
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required TransactionRepository repository,
}) async {
  useIPhoneScreen(tester);
  await tester.pumpWidget(
    ProviderScope(
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

    Finder rowIcon(IconData icon) =>
        find.descendant(of: find.byType(ListTile), matching: find.byIcon(icon));

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
    await _pumpHome(
      tester,
      repository: _FailingRepository(Exception('offline')),
    );

    expect(find.text('Could not load transactions'), findsOneWidget);
  });

  testWidgets('tells a non-staff account it has no access', (tester) async {
    await _pumpHome(
      tester,
      repository: _FailingRepository(const ArchiveAccessDeniedException()),
    );

    expect(find.text(archiveAccessDeniedMessage), findsOneWidget);
    expect(find.text('Could not load transactions'), findsNothing);
  });

  testWidgets('shows "No transactions yet" for an empty archive', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: InMemoryTransactionRepository(
        transactions: [],
        documents: {},
      ),
    );

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}
