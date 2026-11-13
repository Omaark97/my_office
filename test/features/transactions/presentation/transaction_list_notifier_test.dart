import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_draft.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

void main() {
  final fixedNow = DateTime.utc(2024, 7, 1, 12);

  late InMemoryTransactionRepository repository;
  late ProviderContainer container;

  ProviderContainer containerFor({String? signedInUid = 'test-staff-uid'}) {
    final created = ProviderContainer.test(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => fixedNow),
        currentUserIdProvider.overrideWithValue(signedInUid),
      ],
    );
    created.listen(transactionListProvider, (_, _) {});
    return created;
  }

  setUp(() {
    repository = InMemoryTransactionRepository(clock: () => fixedNow);
    container = containerFor();
  });

  TransactionListNotifier notifier() =>
      container.read(transactionListProvider.notifier);

  Future<Transaction> listed(String id) async {
    final transactions = await container.read(transactionListProvider.future);
    return transactions.firstWhere((t) => t.id == id);
  }

  final draft = TransactionDraft(
    type: TransactionType.motorcycleRegistration,
    clientName: '  فاطمة  ',
    clientPhone: ' ٠٣ ١٢٣ ٤٥٦ ',
    dateReceived: DateTime.utc(2024, 6, 30, 12),
  );

  test('loads the transactions from the repository', () async {
    final transactions = await container.read(transactionListProvider.future);

    expect(transactions, hasLength(5));
  });

  group('addTransaction', () {
    test(
      'creates a cleaned, pending transaction for the signed-in user',
      () async {
        final id = await notifier().addTransaction(draft);

        final created = await repository.getTransaction(id);
        expect(created!.status, TransactionStatus.pending);
        expect(created.clientName, 'فاطمة');
        expect(created.clientPhone, '03 123 456');
        expect(created.createdBy, 'test-staff-uid');
      },
    );

    test('the new transaction appears in the reloaded list', () async {
      await container.read(transactionListProvider.future);

      final id = await notifier().addTransaction(draft);

      expect((await listed(id)).clientName, 'فاطمة');
    });

    test('refuses when nobody is signed in', () async {
      container = containerFor(signedInUid: null);

      await expectLater(notifier().addTransaction(draft), throwsStateError);
    });
  });

  group('updateDetails', () {
    test('corrects a pending transaction', () async {
      await notifier().updateDetails('test-2', draft);

      final updated = await listed('test-2');
      expect(updated.clientName, 'فاطمة');
      expect(updated.type, TransactionType.motorcycleRegistration);
      expect(updated.dateReceived, DateTime.utc(2024, 6, 30, 12));
    });

    test('refreshes the single transaction too', () async {
      await container.read(transactionProvider('test-2').future);

      await notifier().updateDetails('test-2', draft);

      final reloaded = await container.read(
        transactionProvider('test-2').future,
      );
      expect(reloaded!.clientName, 'فاطمة');
    });

    test('rejects completed and cancelled transactions', () async {
      await repository.updateStatus('test-4', TransactionStatus.cancelled);

      await expectLater(
        notifier().updateDetails('test-1', draft),
        throwsStateError,
      );
      await expectLater(
        notifier().updateDetails('test-4', draft),
        throwsStateError,
      );
    });
  });

  group('markCompleted', () {
    test('completes a pending transaction', () async {
      await notifier().markCompleted('test-2');

      final updated = await listed('test-2');
      expect(updated.status, TransactionStatus.completed);
      expect(updated.dateCompleted, fixedNow);
      expect(updated.updatedAt, fixedNow);
    });

    test('leaves the other transactions alone', () async {
      Future<Map<String, TransactionStatus>> otherStatuses() async => {
        for (final t in await container.read(transactionListProvider.future))
          if (t.id != 'test-2') t.id: t.status,
      };
      final before = await otherStatuses();

      await notifier().markCompleted('test-2');

      expect(await otherStatuses(), before);
    });

    test('rejects a transaction that is not pending', () async {
      await expectLater(notifier().markCompleted('test-1'), throwsStateError);
    });

    test('rejects an unknown id', () async {
      await expectLater(notifier().markCompleted('nope'), throwsStateError);
    });
  });

  group('markCancelled', () {
    test('cancels a pending transaction without a completed date', () async {
      await notifier().markCancelled('test-4');

      final updated = await listed('test-4');
      expect(updated.status, TransactionStatus.cancelled);
      expect(updated.dateCompleted, isNull);
      expect(updated.updatedAt, fixedNow);
    });

    test('rejects completed and already cancelled transactions', () async {
      await notifier().markCancelled('test-4');

      await expectLater(notifier().markCancelled('test-1'), throwsStateError);
      await expectLater(notifier().markCancelled('test-4'), throwsStateError);
    });
  });

  test('transactionProvider loads one transaction by id', () async {
    final transaction = await container.read(
      transactionProvider('test-3').future,
    );

    expect(transaction!.clientName, 'Test User 3');
    expect(await container.read(transactionProvider('nope').future), isNull);
  });

  test('documents are loaded per transaction', () async {
    final documents = await container.read(
      transactionDocumentsProvider('test-4').future,
    );

    expect(documents.map((d) => d.name), [
      'Buyer_ID.jpg',
      'Seller_ID.jpg',
      'Notary_POA.pdf',
      'Vehicle_Registration.pdf',
    ]);
  });
}
