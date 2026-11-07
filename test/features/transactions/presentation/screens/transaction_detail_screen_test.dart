import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../../test_helpers.dart';

Future<void> _pumpDetail(WidgetTester tester, String transactionId) async {
  useIPhoneScreen(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          InMemoryTransactionRepository(),
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

  testWidgets('still shows the action buttons (wired in step 4)', (
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
}
