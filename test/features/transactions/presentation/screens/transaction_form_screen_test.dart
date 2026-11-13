import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/app/app.dart';
import 'package:my_office/app/router.dart';
import 'package:my_office/app/routes.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/archive_access_denied_exception.dart';
import 'package:my_office/features/transactions/domain/transaction_draft.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';
import 'package:my_office/features/transactions/presentation/load_error_message.dart';
import 'package:my_office/features/transactions/presentation/transaction_icons.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../../auth/fake_auth_repository.dart';
import '../../../../test_helpers.dart';

final _fixedNow = DateTime(2026, 11, 13, 10);

class _RefusingRepository extends InMemoryTransactionRepository {
  @override
  Future<String> createTransaction(
    TransactionDraft draft, {
    required String createdBy,
  }) async {
    throw const ArchiveAccessDeniedException();
  }
}

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

Future<void> _openNewForm(
  WidgetTester tester,
  InMemoryTransactionRepository repository,
) async {
  final container = await _pumpApp(tester, repository);
  container.read(routerProvider).push(AppRoutes.newTransaction);
  await tester.pumpAndSettle();
}

Finder get _nameField => find.widgetWithText(TextFormField, 'Client name');
Finder get _phoneField =>
    find.widgetWithText(TextFormField, 'Phone (optional)');
Finder get _saveButton =>
    find.widgetWithText(ElevatedButton, 'Save Transaction');

Future<void> _chooseType(WidgetTester tester, TransactionType type) async {
  await tester.tap(find.text('Choose a type'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(type.label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the home + button opens the new transaction form', (
    tester,
  ) async {
    await _pumpApp(tester, InMemoryTransactionRepository());

    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();

    expect(find.text('New Transaction'), findsOneWidget);
    expect(find.text('CLIENT'), findsOneWidget);
    expect(find.text('TRANSACTION'), findsOneWidget);
  });

  testWidgets('the date received defaults to today', (tester) async {
    await _openNewForm(tester, InMemoryTransactionRepository());

    expect(find.text('2026-11-13'), findsOneWidget);
  });

  testWidgets('saving empty shows what is missing and saves nothing', (
    tester,
  ) async {
    final repository = InMemoryTransactionRepository();
    await _openNewForm(tester, repository);

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text("Enter the client's name"), findsOneWidget);
    expect(find.text('Choose a transaction type'), findsOneWidget);
    expect(await repository.getTransactions(), hasLength(5));
  });

  testWidgets('a name of only tatweel is treated as empty', (tester) async {
    await _openNewForm(tester, InMemoryTransactionRepository());

    await tester.enterText(_nameField, 'ـــ');
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text("Enter the client's name"), findsOneWidget);
  });

  testWidgets('an Arabic name switches the field to right-to-left', (
    tester,
  ) async {
    await _openNewForm(tester, InMemoryTransactionRepository());
    EditableText nameText() => tester.widget<EditableText>(
      find.descendant(of: _nameField, matching: find.byType(EditableText)),
    );

    expect(nameText().textDirection, TextDirection.ltr);

    await tester.enterText(_nameField, 'سامي يوسف');
    await tester.pump();
    expect(nameText().textDirection, TextDirection.rtl);

    await tester.enterText(_nameField, 'Test User');
    await tester.pump();
    expect(nameText().textDirection, TextDirection.ltr);
  });

  testWidgets('the type picker lists all 10 types with their icons', (
    tester,
  ) async {
    await _openNewForm(tester, InMemoryTransactionRepository());

    await tester.tap(find.text('Choose a type'));
    await tester.pumpAndSettle();

    for (final type in TransactionType.values) {
      final tile = find.widgetWithText(ListTile, type.label);
      expect(tile, findsOneWidget, reason: type.label);
      expect(
        find.descendant(of: tile, matching: find.byIcon(type.icon)),
        findsOneWidget,
        reason: type.label,
      );
    }
  });

  testWidgets('a chosen type is shown with its icon', (tester) async {
    await _openNewForm(tester, InMemoryTransactionRepository());

    await _chooseType(tester, TransactionType.lienRelease);

    expect(find.text('Lien Release'), findsOneWidget);
    expect(find.text('Choose a type'), findsNothing);
  });

  testWidgets('the date picker changes the date received', (tester) async {
    await _openNewForm(tester, InMemoryTransactionRepository());

    await tester.tap(find.text('2026-11-13'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('2026-11-05'), findsOneWidget);
  });

  testWidgets('saving creates the transaction and opens its detail page', (
    tester,
  ) async {
    final repository = InMemoryTransactionRepository();
    await _openNewForm(tester, repository);

    await tester.enterText(_nameField, '  سامي يوسف ');
    await tester.enterText(_phoneField, '٠٣ ١٢٣ ٤٥٦');
    await _chooseType(tester, TransactionType.motorcycleRegistration);
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('سامي يوسف'), findsOneWidget);
    expect(find.text('Motorcycle Registration'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Received: 2026-11-13'), findsOneWidget);

    final saved = (await repository.getTransactions()).firstWhere(
      (t) => t.clientName == 'سامي يوسف',
    );
    expect(saved.status, TransactionStatus.pending);
    expect(saved.clientPhone, '03 123 456');
    expect(saved.createdBy, testUser.uid);
    expect(saved.dateReceived, DateTime(2026, 11, 13, 12).toUtc());
  });

  testWidgets('Back from the new detail page returns home, not to the form', (
    tester,
  ) async {
    await _openNewForm(tester, InMemoryTransactionRepository());
    await tester.enterText(_nameField, 'Test User 6');
    await _chooseType(tester, TransactionType.other);
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('New Transaction'), findsNothing);
    expect(find.text('Test User 6'), findsOneWidget);
  });

  testWidgets('a refused save shows a message and keeps the form', (
    tester,
  ) async {
    await _openNewForm(tester, _RefusingRepository());
    await tester.enterText(_nameField, 'Test User 6');
    await _chooseType(tester, TransactionType.other);

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text(archiveAccessDeniedMessage), findsOneWidget);
    expect(find.text('New Transaction'), findsOneWidget);
    expect(_saveButton, findsOneWidget);
  });
}
