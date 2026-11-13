import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_status.dart';

const transactionPageSize = 50;

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();

  Future<Transaction?> getTransaction(String id);

  Future<List<TransactionDocument>> getDocuments(String transactionId);

  Future<String> createTransaction(
    TransactionDraft draft, {
    required String createdBy,
  });

  Future<void> updateDetails(String id, TransactionDraft draft);

  Future<void> updateStatus(String id, TransactionStatus status);
}
