import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

void main() {
  group('with the default test data', () {
    late InMemoryTransactionRepository repository;

    setUp(() => repository = InMemoryTransactionRepository());

    test('has the 5 test transactions in order', () async {
      final transactions = await repository.getTransactions();

      expect(transactions.map((t) => t.clientName), [
        'Test User 1',
        'Test User 2',
        'Test User 3',
        'Test User 4',
        'Test User 5',
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

  test('updateStatus changes only the given transaction', () async {
    final repository = InMemoryTransactionRepository();
    final now = DateTime.utc(2024, 7, 1, 12);

    await repository.updateStatus(
      'test-2',
      status: TransactionStatus.completed,
      dateCompleted: now,
      updatedAt: now,
    );

    final transactions = await repository.getTransactions();
    expect(transactions[1].status, TransactionStatus.completed);
    expect(transactions[1].dateCompleted, now);
    expect(transactions[3].status, TransactionStatus.pending);
  });

  test('updateStatus throws for an unknown id', () async {
    final repository = InMemoryTransactionRepository();

    expect(
      () => repository.updateStatus(
        'nope',
        status: TransactionStatus.completed,
        updatedAt: DateTime.utc(2024),
      ),
      throwsStateError,
    );
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
}
