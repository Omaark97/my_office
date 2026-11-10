import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_transaction_repository.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => InMemoryTransactionRepository(),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
      TransactionListNotifier.new,
    );

class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).getTransactions();
  }

  Future<void> markCompleted(String id) async {
    final transactions = await future;
    final transaction = transactions.firstWhere(
      (t) => t.id == id,
      orElse: () => throw StateError('No transaction with id "$id"'),
    );
    if (transaction.status != TransactionStatus.pending) {
      throw StateError(
        'Only pending transactions can be completed. '
        '"$id" is ${transaction.status.key}.',
      );
    }

    await ref
        .read(transactionRepositoryProvider)
        .updateStatus(id, TransactionStatus.completed);

    if (!ref.mounted) return;
    final now = ref.read(clockProvider)().toUtc();
    state = AsyncData([
      for (final t in transactions)
        if (t.id == id)
          t.copyWith(
            status: TransactionStatus.completed,
            dateCompleted: now,
            updatedAt: now,
          )
        else
          t,
    ]);
  }
}

final transactionDocumentsProvider =
    FutureProvider.family<List<TransactionDocument>, String>(
      (ref, transactionId) =>
          ref.watch(transactionRepositoryProvider).getDocuments(transactionId),
    );
