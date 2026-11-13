import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/firestore_transaction_mapping.dart';
import 'package:my_office/features/transactions/domain/archive_access_denied_exception.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

Transaction _pendingTransaction({String clientName = 'Test User 1'}) {
  return Transaction(
    id: 'tx-1',
    type: TransactionType.lienRelease,
    clientName: clientName,
    status: TransactionStatus.pending,
    dateReceived: DateTime.utc(2024, 5, 15, 12),
    createdBy: 'test-staff-uid',
    createdAt: DateTime.utc(2024, 5, 15, 12),
    updatedAt: DateTime.utc(2024, 5, 15, 12),
  );
}

void main() {
  group('transactionFromFirestore', () {
    test('turns Timestamps into UTC DateTimes', () {
      final transaction = transactionFromFirestore('tx-1', {
        'type': 'lienRelease',
        'clientName': 'Test User 1',
        'clientNameLower': 'test user 1',
        'clientPhone': null,
        'customerId': null,
        'status': 'completed',
        'dateReceived': Timestamp.fromDate(DateTime.utc(2024, 5, 15, 12)),
        'dateCompleted': Timestamp.fromDate(DateTime.utc(2024, 5, 20, 9)),
        'createdBy': 'test-staff-uid',
        'createdAt': Timestamp.fromDate(DateTime.utc(2024, 5, 15, 12)),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2024, 5, 20, 9)),
      });

      expect(transaction.id, 'tx-1');
      expect(transaction.status, TransactionStatus.completed);
      expect(transaction.dateReceived, DateTime.utc(2024, 5, 15, 12));
      expect(transaction.dateReceived.isUtc, isTrue);
      expect(transaction.dateCompleted, DateTime.utc(2024, 5, 20, 9));
    });
  });

  group('documentFromFirestore', () {
    test('turns uploadedAt into a UTC DateTime', () {
      final document = documentFromFirestore('doc-1', {
        'name': 'ID_Front.jpg',
        'mimeType': 'image/jpeg',
        'sizeBytes': 1258291,
        'category': 'identification',
        'uploadedAt': Timestamp.fromDate(DateTime.utc(2024, 5, 15, 12)),
        'uploadedBy': 'test-staff-uid',
        'storagePath': 'transactions/tx-1/documents/doc-1.jpg',
      });

      expect(document.category, DocumentCategory.identification);
      expect(document.uploadedAt, DateTime.utc(2024, 5, 15, 12));
    });
  });

  group('newTransactionToFirestore', () {
    test('adds the normalized search key', () {
      final data = newTransactionToFirestore(
        _pendingTransaction(clientName: '  أَحمـد   مصطفى  '),
      );

      expect(data['clientName'], '  أَحمـد   مصطفى  ');
      expect(data['clientNameLower'], 'احمد مصطفي');
    });

    test('uses server time for createdAt and updatedAt', () {
      final data = newTransactionToFirestore(_pendingTransaction());

      expect(data['createdAt'], FieldValue.serverTimestamp());
      expect(data['updatedAt'], FieldValue.serverTimestamp());
      expect(data['dateCompleted'], isNull);
    });

    test('keeps dateReceived as entered and saves enums by key', () {
      final data = newTransactionToFirestore(_pendingTransaction());

      expect(
        data['dateReceived'],
        Timestamp.fromDate(DateTime.utc(2024, 5, 15, 12)),
      );
      expect(data['type'], 'lienRelease');
      expect(data['status'], 'pending');
      expect(data['customerId'], isNull);
      expect(data.containsKey('id'), isFalse);
    });
  });

  group('statusChangeToFirestore', () {
    test('completing sets status, dateCompleted and updatedAt', () {
      expect(statusChangeToFirestore(TransactionStatus.completed), {
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
        'dateCompleted': FieldValue.serverTimestamp(),
      });
    });

    test('cancelling sets only status and updatedAt', () {
      expect(statusChangeToFirestore(TransactionStatus.cancelled), {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  });

  group('repositoryErrorFrom', () {
    test('permission-denied means no access to the archive', () {
      final error = repositoryErrorFrom(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(error, isA<ArchiveAccessDeniedException>());
    });

    test('not-found becomes a StateError', () {
      final error = repositoryErrorFrom(
        FirebaseException(plugin: 'cloud_firestore', code: 'not-found'),
      );

      expect(error, isA<StateError>());
    });

    test('other errors are passed on unchanged', () {
      final original = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

      expect(repositoryErrorFrom(original), same(original));
    });
  });
}
