import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

void main() {
  final fixedNow = DateTime.utc(2024, 7, 1, 12);

  late InMemoryTransactionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryTransactionRepository();
    container = ProviderContainer.test(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => fixedNow),
      ],
    );
  });

  test('loads the transactions from the repository', () async {
    final transactions = await container.read(transactionListProvider.future);

    expect(transactions, hasLength(5));
  });

  test('markCompleted completes a pending transaction', () async {
    await container.read(transactionListProvider.future);

    await container
        .read(transactionListProvider.notifier)
        .markCompleted('test-2');

    final updated = container
        .read(transactionListProvider)
        .requireValue
        .firstWhere((t) => t.id == 'test-2');
    expect(updated.status, TransactionStatus.completed);
    expect(updated.dateCompleted, fixedNow);
    expect(updated.updatedAt, fixedNow);
  });

  test('markCompleted saves the change in the repository', () async {
    await container
        .read(transactionListProvider.notifier)
        .markCompleted('test-2');

    final saved = (await repository.getTransactions()).firstWhere(
      (t) => t.id == 'test-2',
    );
    expect(saved.status, TransactionStatus.completed);
    expect(saved.dateCompleted, fixedNow);
  });

  test('markCompleted leaves the other transactions alone', () async {
    Map<String, TransactionStatus> otherStatuses() => {
      for (final t in container.read(transactionListProvider).requireValue)
        if (t.id != 'test-2') t.id: t.status,
    };
    await container.read(transactionListProvider.future);
    final before = otherStatuses();

    await container
        .read(transactionListProvider.notifier)
        .markCompleted('test-2');

    expect(otherStatuses(), before);
  });

  test('markCompleted rejects a transaction that is not pending', () async {
    final notifier = container.read(transactionListProvider.notifier);

    await expectLater(notifier.markCompleted('test-1'), throwsStateError);
  });

  test('markCompleted rejects an unknown id', () async {
    final notifier = container.read(transactionListProvider.notifier);

    await expectLater(notifier.markCompleted('nope'), throwsStateError);
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
