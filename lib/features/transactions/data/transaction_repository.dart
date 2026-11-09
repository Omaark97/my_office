import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();

  Future<List<TransactionDocument>> getDocuments(String transactionId);

  Future<void> updateStatus(
    String id, {
    required TransactionStatus status,
    DateTime? dateCompleted,
    required DateTime updatedAt,
  });
}
