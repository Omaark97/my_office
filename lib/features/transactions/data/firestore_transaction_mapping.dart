import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../domain/archive_access_denied_exception.dart';
import '../domain/client_name_search_key.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';

Transaction transactionFromFirestore(String id, Map<String, dynamic> data) {
  return Transaction.fromMap(id, _withDateTimes(data));
}

TransactionDocument documentFromFirestore(
  String id,
  Map<String, dynamic> data,
) {
  return TransactionDocument.fromMap(id, _withDateTimes(data));
}

Map<String, dynamic> newTransactionToFirestore(Transaction transaction) {
  return {
    ...transaction.toMap(),
    'clientNameLower': clientNameSearchKey(transaction.clientName),
    'dateReceived': Timestamp.fromDate(transaction.dateReceived),
    'dateCompleted': null,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Map<String, dynamic> statusChangeToFirestore(TransactionStatus status) {
  return {
    'status': status.key,
    'updatedAt': FieldValue.serverTimestamp(),
    if (status == TransactionStatus.completed)
      'dateCompleted': FieldValue.serverTimestamp(),
  };
}

Object repositoryErrorFrom(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return const ArchiveAccessDeniedException();
    case 'not-found':
      return StateError('Transaction not found: ${error.message}');
    default:
      return error;
  }
}

Map<String, dynamic> _withDateTimes(Map<String, dynamic> data) {
  return data.map(
    (field, value) =>
        MapEntry(field, value is Timestamp ? value.toDate().toUtc() : value),
  );
}
