import '../domain/new_document.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_status.dart';

const transactionPageSize = 50;

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();

  Future<Transaction?> getTransaction(String id);

  Future<List<TransactionDocument>> getDocuments(String transactionId);

  String newDocumentId(String transactionId);

  Future<void> addDocument(
    String transactionId,
    String documentId,
    NewDocument document, {
    required String uploadedBy,
  });

  Future<String> createTransaction(
    TransactionDraft draft, {
    required String createdBy,
  });

  Future<void> updateDetails(String id, TransactionDraft draft);

  Future<void> updateStatus(String id, TransactionStatus status);
}
