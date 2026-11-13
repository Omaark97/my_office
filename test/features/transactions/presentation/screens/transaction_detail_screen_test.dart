import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/data/transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';
import 'package:my_office/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../../test_helpers.dart';

Future<void> _pumpDetail(
  WidgetTester tester,
  String transactionId, {
  InMemoryTransactionRepository? repository,
}) async {
  useIPhoneScreen(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          repository ?? InMemoryTransactionRepository(),
        ),
      ],
      child: MaterialApp(
        home: TransactionDetailScreen(transactionId: transactionId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a completed transaction with its documents', (
    tester,
  ) async {
    await _pumpDetail(tester, 'test-1');

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Public Taxi Registration'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Received: 2024-05-15'), findsOneWidget);
    expect(find.text('Completed: 2024-05-15'), findsOneWidget);
    expect(find.text('Test User 1'), findsOneWidget);

    expect(find.text('3 files'), findsOneWidget);
    expect(find.text('ID_Front.jpg'), findsOneWidget);
    expect(find.text('Uploaded 2024-05-15 • 1.2 MB'), findsOneWidget);
    expect(find.text('Sale_Deed.pdf'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsNWidgets(2));
    expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('shows a pending transaction without a completed date', (
    tester,
  ) async {
    await _pumpDetail(tester, 'test-5');

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Received: 2024-05-30'), findsOneWidget);
    expect(find.textContaining('Completed:'), findsNothing);
    expect(find.text('0 files'), findsOneWidget);
    expect(find.text('No documents uploaded yet'), findsOneWidget);
  });

  testWidgets('uses "file" for a single document', (tester) async {
    await _pumpDetail(tester, 'test-3');

    expect(find.text('1 file'), findsOneWidget);
    expect(find.text('Uploaded 2024-04-15 • 0.8 MB'), findsOneWidget);
  });

  testWidgets('shows the action buttons for a pending transaction', (
    tester,
  ) async {
    await _pumpDetail(tester, 'test-2');

    expect(find.text('Complete Transaction'), findsOneWidget);
    expect(find.text('Cancel Transaction'), findsOneWidget);
  });

  testWidgets('shows a message for an unknown transaction', (tester) async {
    await _pumpDetail(tester, 'does-not-exist');

    expect(find.text('Transaction not found'), findsOneWidget);
  });

  testWidgets('opens a back-dated transaction that is not in the list page', (
    tester,
  ) async {
    Transaction pending(String id, String name, DateTime received) {
      return Transaction(
        id: id,
        type: TransactionType.other,
        clientName: name,
        status: TransactionStatus.pending,
        dateReceived: received,
        createdBy: 'test-staff-uid',
        createdAt: received,
        updatedAt: received,
      );
    }

    final repository = InMemoryTransactionRepository(
      transactions: [
        for (var i = 0; i < transactionPageSize; i++)
          pending(
            'recent-$i',
            'Test User $i',
            DateTime.utc(2024, 1, 1, 12).add(Duration(days: i)),
          ),
        pending(
          'old-paper-file',
          'Test User Old',
          DateTime.utc(1985, 3, 1, 12),
        ),
      ],
      documents: {},
    );

    await _pumpDetail(tester, 'old-paper-file', repository: repository);

    expect(find.text('Test User Old'), findsOneWidget);
    expect(find.text('Received: 1985-03-01'), findsOneWidget);
  });

  testWidgets('shows a grey "Cancelled" badge', (tester) async {
    final repository = InMemoryTransactionRepository();
    await repository.updateStatus('test-4', TransactionStatus.cancelled);

    await _pumpDetail(tester, 'test-4', repository: repository);

    final badgeText = tester.widget<Text>(find.text('Cancelled'));
    expect(badgeText.style!.color, Colors.grey.shade700);
    expect(find.textContaining('Completed:'), findsNothing);
  });

  group('action buttons', () {
    Finder completeButton() =>
        find.widgetWithText(ElevatedButton, 'Complete Transaction');
    Finder cancelButton() =>
        find.widgetWithText(OutlinedButton, 'Cancel Transaction');

    testWidgets('are hidden for a completed transaction', (tester) async {
      await _pumpDetail(tester, 'test-1');

      expect(completeButton(), findsNothing);
      expect(cancelButton(), findsNothing);
    });

    testWidgets('are hidden for a cancelled transaction', (tester) async {
      final repository = InMemoryTransactionRepository();
      await repository.updateStatus('test-4', TransactionStatus.cancelled);

      await _pumpDetail(tester, 'test-4', repository: repository);

      expect(completeButton(), findsNothing);
      expect(cancelButton(), findsNothing);
    });

    testWidgets('Complete asks first, and "Keep it" changes nothing', (
      tester,
    ) async {
      final repository = InMemoryTransactionRepository();
      await _pumpDetail(tester, 'test-2', repository: repository);

      await tester.ensureVisible(completeButton());
      await tester.tap(completeButton());
      await tester.pumpAndSettle();
      expect(find.text('Complete this transaction?'), findsOneWidget);

      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();

      expect(find.text('Complete this transaction?'), findsNothing);
      expect(
        (await repository.getTransaction('test-2'))!.status,
        TransactionStatus.pending,
      );
      expect(completeButton(), findsOneWidget);
    });

    testWidgets('confirming Complete completes it and hides the buttons', (
      tester,
    ) async {
      final repository = InMemoryTransactionRepository();
      await _pumpDetail(tester, 'test-2', repository: repository);

      await tester.ensureVisible(completeButton());
      await tester.tap(completeButton());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Complete'));
      await tester.pumpAndSettle();

      expect(
        (await repository.getTransaction('test-2'))!.status,
        TransactionStatus.completed,
      );
      expect(find.text('Transaction completed'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(completeButton(), findsNothing);
      expect(cancelButton(), findsNothing);
    });

    testWidgets('confirming Cancel cancels it and hides the buttons', (
      tester,
    ) async {
      final repository = InMemoryTransactionRepository();
      await _pumpDetail(tester, 'test-4', repository: repository);

      await tester.ensureVisible(cancelButton());
      await tester.tap(cancelButton());
      await tester.pumpAndSettle();
      expect(find.text('Cancel this transaction?'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Cancel transaction'),
      );
      await tester.pumpAndSettle();

      expect(
        (await repository.getTransaction('test-4'))!.status,
        TransactionStatus.cancelled,
      );
      expect(find.text('Transaction cancelled'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(cancelButton(), findsNothing);
    });
  });
}
