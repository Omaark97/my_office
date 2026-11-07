import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_transaction_repository.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';

/// The repository the whole app uses.
///
/// Tests replace it with `transactionRepositoryProvider.overrideWithValue(...)`.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => InMemoryTransactionRepository(),
);

/// Gives the current time. Tests replace it with a fixed time, so results do
/// not depend on when (or in which time zone) the tests run.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The list of transactions shown on the home screen.
final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
      TransactionListNotifier.new,
    );

/// Loads the transactions and is the only place that changes their status.
///
/// Widgets call its methods; they never change a transaction themselves.
class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).getTransactions();
  }

  /// Marks a pending transaction as completed, today.
  ///
  /// Throws a [StateError] if there is no transaction with [id], or if it is
  /// not pending.
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

    final now = ref.read(clockProvider)().toUtc();
    await ref
        .read(transactionRepositoryProvider)
        .updateStatus(
          id,
          status: TransactionStatus.completed,
          dateCompleted: now,
          updatedAt: now,
        );

    // The provider may have been disposed while we were waiting.
    if (!ref.mounted) return;
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

/// The documents of one transaction, loaded only when its detail screen
/// is opened.
final transactionDocumentsProvider =
    FutureProvider.family<List<TransactionDocument>, String>(
      (ref, transactionId) =>
          ref.watch(transactionRepositoryProvider).getDocuments(transactionId),
    );
