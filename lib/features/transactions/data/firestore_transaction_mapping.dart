import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../domain/archive_access_denied_exception.dart';
import '../domain/client_name_search_key.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_draft.dart';
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

Map<String, dynamic> newTransactionToFirestore(
  TransactionDraft draft, {
  required String createdBy,
}) {
  return {
    ..._detailsOf(draft),
    'customerId': null,
    'status': TransactionStatus.pending.key,
    'dateCompleted': null,
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Map<String, dynamic> detailsChangeToFirestore(TransactionDraft draft) {
  return {..._detailsOf(draft), 'updatedAt': FieldValue.serverTimestamp()};
}

Map<String, dynamic> _detailsOf(TransactionDraft draft) {
  return {
    'type': draft.type.key,
    'clientName': draft.clientName,
    'clientNameLower': clientNameSearchKey(draft.clientName),
    'clientPhone': draft.clientPhone,
    'dateReceived': Timestamp.fromDate(draft.dateReceived),
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
