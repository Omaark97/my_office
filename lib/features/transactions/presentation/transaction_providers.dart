import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/firestore_transaction_repository.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_status.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => FirestoreTransactionRepository(),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
      TransactionListNotifier.new,
    );

final transactionProvider = FutureProvider.family<Transaction?, String>(
  (ref, id) => ref.watch(transactionRepositoryProvider).getTransaction(id),
);

class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).getTransactions();
  }

  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  Future<String> addTransaction(TransactionDraft draft) async {
    final createdBy = ref.read(currentUserIdProvider);
    if (createdBy == null) {
      throw StateError('Sign in before adding a transaction');
    }
    final id = await _repository.createTransaction(
      draft.cleaned(),
      createdBy: createdBy,
    );
    _reload(id);
    return id;
  }

  Future<void> updateDetails(String id, TransactionDraft draft) async {
    await _requirePending(id, action: 'edited');
    await _repository.updateDetails(id, draft.cleaned());
    _reload(id);
  }

  Future<void> markCompleted(String id) async {
    await _requirePending(id, action: 'completed');
    await _repository.updateStatus(id, TransactionStatus.completed);
    _reload(id);
  }

  Future<void> markCancelled(String id) async {
    await _requirePending(id, action: 'cancelled');
    await _repository.updateStatus(id, TransactionStatus.cancelled);
    _reload(id);
  }

  Future<void> _requirePending(String id, {required String action}) async {
    final transaction = await _repository.getTransaction(id);
    if (transaction == null) {
      throw StateError('No transaction with id "$id"');
    }
    if (transaction.status != TransactionStatus.pending) {
      throw StateError(
        'Only pending transactions can be $action. '
        '"$id" is ${transaction.status.key}.',
      );
    }
  }

  void _reload(String id) {
    if (!ref.mounted) return;
    ref.invalidate(transactionProvider(id));
    ref.invalidateSelf();
  }
}

final transactionDocumentsProvider =
    FutureProvider.family<List<TransactionDocument>, String>(
      (ref, transactionId) =>
          ref.watch(transactionRepositoryProvider).getDocuments(transactionId),
    );
