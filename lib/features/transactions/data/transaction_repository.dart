import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';

/// Where transactions are loaded from and saved to.
///
/// The rest of the app only knows this interface. Today it is backed by
/// [InMemoryTransactionRepository]; in step 3 a Firestore version is added
/// without changing any screen.
///
/// There is deliberately no delete: transactions are archival records.
abstract class TransactionRepository {
  /// All transactions, in display order.
  Future<List<Transaction>> getTransactions();

  /// The documents attached to the transaction with [transactionId].
  /// Returns an empty list if it has none.
  Future<List<TransactionDocument>> getDocuments(String transactionId);

  /// Changes the status of the transaction with [id].
  ///
  /// Throws a [StateError] if there is no such transaction.
  Future<void> updateStatus(
    String id, {
    required TransactionStatus status,
    DateTime? dateCompleted,
    required DateTime updatedAt,
  });
}
