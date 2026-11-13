import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/app/app.dart';
import 'package:my_office/app/router.dart';
import 'package:my_office/app/routes.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../auth/fake_auth_repository.dart';
import '../../../../test_helpers.dart';

final _fixedNow = DateTime(2026, 11, 13, 10);

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  InMemoryTransactionRepository repository,
) async {
  useIPhoneScreen(tester);
  final container = ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(signedInUser: testUser),
      ),
      transactionRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => _fixedNow),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _openDetail(
  WidgetTester tester,
  InMemoryTransactionRepository repository,
  String id,
) async {
  final container = await _pumpApp(tester, repository);
  container.read(routerProvider).push(AppRoutes.transaction(id));
  await tester.pumpAndSettle();
}

Finder get _nameField => find.widgetWithText(TextFormField, 'Client name');
Finder get _phoneField =>
    find.widgetWithText(TextFormField, 'Phone (optional)');

void main() {
  group('edit icon', () {
    testWidgets('is shown for a pending transaction', (tester) async {
      await _openDetail(tester, InMemoryTransactionRepository(), 'test-2');

      expect(find.byTooltip('Edit'), findsOneWidget);
    });

    testWidgets('is hidden for completed and cancelled transactions', (
      tester,
    ) async {
      final repository = InMemoryTransactionRepository();
      await repository.updateStatus('test-4', TransactionStatus.cancelled);

      await _openDetail(tester, repository, 'test-1');
      expect(find.byTooltip('Edit'), findsNothing);

      await _openDetail(tester, repository, 'test-4');
      expect(find.byTooltip('Edit'), findsNothing);
    });
  });

  testWidgets('the edit form is prefilled', (tester) async {
    await _openDetail(tester, InMemoryTransactionRepository(), 'test-2');

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(_nameField).controller!.text,
      'Test User 2',
    );
    expect(find.text("Driver's License Renewal"), findsOneWidget);
    expect(find.text('2024-06-01'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Save Changes'), findsOneWidget);
  });

  testWidgets('saving changes updates the transaction and returns to it', (
    tester,
  ) async {
    final repository = InMemoryTransactionRepository();
    await _openDetail(tester, repository, 'test-2');
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(_nameField, 'Test User Two');
    await tester.enterText(_phoneField, '71 123 456');
    await tester.tap(find.text("Driver's License Renewal"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Changes saved'), findsOneWidget);
    expect(find.text('Test User Two'), findsOneWidget);

    final saved = await repository.getTransaction('test-2');
    expect(saved!.clientName, 'Test User Two');
    expect(saved.clientPhone, '71 123 456');
    expect(saved.type, TransactionType.other);
    expect(saved.status, TransactionStatus.pending);
  });

  testWidgets('the date received can be corrected', (tester) async {
    final repository = InMemoryTransactionRepository();
    await _openDetail(tester, repository, 'test-2');
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('2024-06-01'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Received: 2024-06-03'), findsOneWidget);
    expect(
      (await repository.getTransaction('test-2'))!.dateReceived,
      DateTime(2024, 6, 3, 12).toUtc(),
    );
  });

  testWidgets('a completed transaction cannot be opened for editing', (
    tester,
  ) async {
    final container = await _pumpApp(tester, InMemoryTransactionRepository());

    container.read(routerProvider).push(AppRoutes.editTransaction('test-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Only pending transactions can be edited.'),
      findsOneWidget,
    );
    expect(_nameField, findsNothing);
  });
}
