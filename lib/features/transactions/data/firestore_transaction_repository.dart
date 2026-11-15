import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../domain/new_document.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_status.dart';
import 'firestore_transaction_mapping.dart';
import 'transaction_repository.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _withEstimatedServerTimes = GetOptions(
    serverTimestampBehavior: ServerTimestampBehavior.estimate,
  );

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore.collection('transactions');

  @override
  Future<List<Transaction>> getTransactions() {
    return _guard(() async {
      final snapshot = await _transactions
          .orderBy('dateReceived', descending: true)
          .limit(transactionPageSize)
          .get(_withEstimatedServerTimes);
      return [
        for (final doc in snapshot.docs)
          transactionFromFirestore(doc.id, doc.data()),
      ];
    });
  }

  @override
  Future<List<TransactionDocument>> getDocuments(String transactionId) {
    return _guard(() async {
      final snapshot = await _transactions
          .doc(transactionId)
          .collection('documents')
          .orderBy('uploadedAt')
          .get(_withEstimatedServerTimes);
      return [
        for (final doc in snapshot.docs)
          documentFromFirestore(doc.id, doc.data()),
      ];
    });
  }

  @override
  Future<Transaction?> getTransaction(String id) {
    return _guard(() async {
      final snapshot = await _transactions
          .doc(id)
          .get(_withEstimatedServerTimes);
      final data = snapshot.data();
      return data == null ? null : transactionFromFirestore(snapshot.id, data);
    });
  }

  @override
  String newDocumentId(String transactionId) {
    return _documentsOf(transactionId).doc().id;
  }

  @override
  Future<void> addDocument(
    String transactionId,
    String documentId,
    NewDocument document, {
    required String uploadedBy,
  }) {
    return _guard(
      () => _documentsOf(transactionId)
          .doc(documentId)
          .set(newDocumentToFirestore(document, uploadedBy: uploadedBy)),
    );
  }

  CollectionReference<Map<String, dynamic>> _documentsOf(String transactionId) {
    return _transactions.doc(transactionId).collection('documents');
  }

  @override
  Future<String> createTransaction(
    TransactionDraft draft, {
    required String createdBy,
  }) {
    return _guard(() async {
      final newDocument = _transactions.doc();
      await newDocument.set(
        newTransactionToFirestore(draft, createdBy: createdBy),
      );
      return newDocument.id;
    });
  }

  @override
  Future<void> updateDetails(String id, TransactionDraft draft) {
    return _guard(
      () => _transactions.doc(id).update(detailsChangeToFirestore(draft)),
    );
  }

  @override
  Future<void> updateStatus(String id, TransactionStatus status) {
    return _guard(
      () => _transactions.doc(id).update(statusChangeToFirestore(status)),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw repositoryErrorFrom(error);
    }
  }
}
