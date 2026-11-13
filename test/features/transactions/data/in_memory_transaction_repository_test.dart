import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/data/transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_draft.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

void main() {
  group('with the default test data', () {
    late InMemoryTransactionRepository repository;

    setUp(() => repository = InMemoryTransactionRepository());

    test('returns the test transactions newest received first', () async {
      final transactions = await repository.getTransactions();

      expect(transactions.map((t) => t.clientName), [
        'Test User 2',
        'Test User 5',
        'Test User 4',
        'Test User 1',
        'Test User 3',
      ]);
    });

    test('gives each transaction its documents', () async {
      expect(await repository.getDocuments('test-1'), hasLength(3));
      expect(await repository.getDocuments('test-4'), hasLength(4));
      expect(await repository.getDocuments('test-5'), isEmpty);
    });

    test('returns an empty list for an unknown transaction id', () async {
      expect(await repository.getDocuments('nope'), isEmpty);
    });

    test('document storage paths sit in the transaction folder', () async {
      for (final transaction in await repository.getTransactions()) {
        for (final doc in await repository.getDocuments(transaction.id)) {
          expect(
            doc.storagePath,
            startsWith('transactions/${transaction.id}/documents/'),
          );
        }
      }
    });
  });

  group('updateStatus', () {
    final now = DateTime.utc(2024, 7, 1, 12);
    late InMemoryTransactionRepository repository;

    setUp(() => repository = InMemoryTransactionRepository(clock: () => now));

    Future<Transaction> saved(String id) async =>
        (await repository.getTransactions()).firstWhere((t) => t.id == id);

    test('completing sets dateCompleted and updatedAt to now', () async {
      await repository.updateStatus('test-2', TransactionStatus.completed);

      final transaction = await saved('test-2');
      expect(transaction.status, TransactionStatus.completed);
      expect(transaction.dateCompleted, now);
      expect(transaction.updatedAt, now);
    });

    test('cancelling sets updatedAt but no dateCompleted', () async {
      await repository.updateStatus('test-4', TransactionStatus.cancelled);

      final transaction = await saved('test-4');
      expect(transaction.status, TransactionStatus.cancelled);
      expect(transaction.dateCompleted, isNull);
      expect(transaction.updatedAt, now);
    });

    test('changes only the given transaction', () async {
      await repository.updateStatus('test-2', TransactionStatus.completed);

      expect((await saved('test-4')).status, TransactionStatus.pending);
    });

    test('throws for an unknown id', () async {
      expect(
        () => repository.updateStatus('nope', TransactionStatus.completed),
        throwsStateError,
      );
    });
  });

  test('returns at most one page of transactions', () async {
    final many = [
      for (var i = 0; i < transactionPageSize + 5; i++)
        Transaction(
          id: 'tx-$i',
          type: TransactionType.other,
          clientName: 'Test User $i',
          status: TransactionStatus.pending,
          dateReceived: DateTime.utc(2024, 1, 1, 12).add(Duration(days: i)),
          createdBy: 'test-staff-uid',
          createdAt: DateTime.utc(2024, 1, 1, 12),
          updatedAt: DateTime.utc(2024, 1, 1, 12),
        ),
    ];
    final repository = InMemoryTransactionRepository(
      transactions: many,
      documents: {},
    );

    final transactions = await repository.getTransactions();

    expect(transactions, hasLength(transactionPageSize));
    expect(transactions.first.id, 'tx-${transactionPageSize + 4}');
  });

  test('can start with custom data', () async {
    final repository = InMemoryTransactionRepository(
      transactions: [
        Transaction(
          id: 'x',
          type: TransactionType.other,
          clientName: 'Test User 9',
          status: TransactionStatus.pending,
          dateReceived: DateTime.utc(2024, 1, 1, 12),
          createdBy: 'test-staff-uid',
          createdAt: DateTime.utc(2024, 1, 1, 12),
          updatedAt: DateTime.utc(2024, 1, 1, 12),
        ),
      ],
      documents: {},
    );

    final transactions = await repository.getTransactions();
    expect(transactions.single.clientName, 'Test User 9');
  });

  group('create, read and correct', () {
    final now = DateTime.utc(2024, 7, 1, 9);
    late InMemoryTransactionRepository repository;

    setUp(() => repository = InMemoryTransactionRepository(clock: () => now));

    test('createTransaction adds a pending transaction', () async {
      final id = await repository.createTransaction(
        TransactionDraft(
          type: TransactionType.lienRelease,
          clientName: 'Test User 6',
          clientPhone: '03 123 456',
          dateReceived: DateTime.utc(2024, 6, 30, 12),
        ),
        createdBy: 'test-staff-uid',
      );

      final created = await repository.getTransaction(id);
      expect(created!.status, TransactionStatus.pending);
      expect(created.clientName, 'Test User 6');
      expect(created.clientPhone, '03 123 456');
      expect(created.createdBy, 'test-staff-uid');
      expect(created.createdAt, now);
      expect((await repository.getTransactions()).first.id, id);
    });

    test('getTransaction returns null for an unknown id', () async {
      expect(await repository.getTransaction('nope'), isNull);
    });

    test('updateDetails changes only the details and updatedAt', () async {
      await repository.updateDetails(
        'test-2',
        TransactionDraft(
          type: TransactionType.other,
          clientName: 'Test User Two',
          dateReceived: DateTime.utc(2024, 5, 1, 12),
        ),
      );

      final updated = await repository.getTransaction('test-2');
      expect(updated!.clientName, 'Test User Two');
      expect(updated.clientPhone, isNull);
      expect(updated.type, TransactionType.other);
      expect(updated.dateReceived, DateTime.utc(2024, 5, 1, 12));
      expect(updated.updatedAt, now);
      expect(updated.status, TransactionStatus.pending);
      expect(updated.createdBy, 'test-staff-uid');
    });

    test('updateDetails throws for an unknown id', () async {
      expect(
        () => repository.updateDetails(
          'nope',
          TransactionDraft(
            type: TransactionType.other,
            clientName: 'Test User 9',
            dateReceived: DateTime.utc(2024, 1, 1, 12),
          ),
        ),
        throwsStateError,
      );
    });
  });
}
