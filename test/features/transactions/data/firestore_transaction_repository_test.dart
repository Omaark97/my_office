import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/data/firestore_transaction_mapping.dart';
import 'package:my_office/features/transactions/data/firestore_transaction_repository.dart';
import 'package:my_office/features/transactions/data/transaction_repository.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

Map<String, dynamic> _savedTransaction({
  required String clientName,
  required DateTime dateReceived,
  String status = 'pending',
}) {
  final time = Timestamp.fromDate(dateReceived);
  return {
    'type': 'other',
    'clientName': clientName,
    'clientNameLower': clientName.toLowerCase(),
    'clientPhone': null,
    'customerId': null,
    'status': status,
    'dateReceived': time,
    'dateCompleted': null,
    'createdBy': 'test-staff-uid',
    'createdAt': time,
    'updatedAt': time,
  };
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreTransactionRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreTransactionRepository(firestore: firestore);
  });

  CollectionReference<Map<String, dynamic>> transactions() =>
      firestore.collection('transactions');

  group('getTransactions', () {
    test('returns an empty list when there are none', () async {
      expect(await repository.getTransactions(), isEmpty);
    });

    test('returns transactions newest received first', () async {
      await transactions()
          .doc('old')
          .set(
            _savedTransaction(
              clientName: 'Test User 1',
              dateReceived: DateTime.utc(2024, 4, 15, 12),
            ),
          );
      await transactions()
          .doc('new')
          .set(
            _savedTransaction(
              clientName: 'Test User 2',
              dateReceived: DateTime.utc(2024, 6, 1, 12),
            ),
          );

      final result = await repository.getTransactions();

      expect(result.map((t) => t.id), ['new', 'old']);
      expect(result.first.dateReceived, DateTime.utc(2024, 6, 1, 12));
    });

    test('returns at most one page', () async {
      for (var i = 0; i < transactionPageSize + 3; i++) {
        await transactions()
            .doc('tx-$i')
            .set(
              _savedTransaction(
                clientName: 'Test User $i',
                dateReceived: DateTime.utc(
                  2024,
                  1,
                  1,
                  12,
                ).add(Duration(days: i)),
              ),
            );
      }

      final result = await repository.getTransactions();

      expect(result, hasLength(transactionPageSize));
    });
  });

  group('getDocuments', () {
    test('returns the documents of one transaction, oldest first', () async {
      final documents = transactions().doc('tx-1').collection('documents');
      Map<String, dynamic> document(String name, DateTime uploadedAt) => {
        'name': name,
        'mimeType': 'image/jpeg',
        'sizeBytes': 1000,
        'category': 'identification',
        'uploadedAt': Timestamp.fromDate(uploadedAt),
        'uploadedBy': 'test-staff-uid',
        'storagePath': 'transactions/tx-1/documents/$name',
      };
      await documents
          .doc('b')
          .set(document('Second.jpg', DateTime.utc(2024, 5, 16)));
      await documents
          .doc('a')
          .set(document('First.jpg', DateTime.utc(2024, 5, 15)));

      final result = await repository.getDocuments('tx-1');

      expect(result.map((d) => d.name), ['First.jpg', 'Second.jpg']);
      expect(await repository.getDocuments('other'), isEmpty);
    });
  });

  group('updateStatus', () {
    setUp(() async {
      await transactions()
          .doc('tx-1')
          .set(
            _savedTransaction(
              clientName: 'Test User 1',
              dateReceived: DateTime.utc(2024, 5, 15, 12),
            ),
          );
    });

    Future<Map<String, dynamic>> saved() async =>
        (await transactions().doc('tx-1').get()).data()!;

    test('completing sets status, dateCompleted and updatedAt', () async {
      await repository.updateStatus('tx-1', TransactionStatus.completed);

      final data = await saved();
      expect(data['status'], 'completed');
      expect(data['dateCompleted'], isA<Timestamp>());
      expect(data['updatedAt'], isNot(data['createdAt']));
    });

    test('cancelling leaves dateCompleted empty', () async {
      await repository.updateStatus('tx-1', TransactionStatus.cancelled);

      final data = await saved();
      expect(data['status'], 'cancelled');
      expect(data['dateCompleted'], isNull);
    });

    test('does not touch the other fields', () async {
      final before = await saved();

      await repository.updateStatus('tx-1', TransactionStatus.completed);

      final after = await saved();
      for (final field in [
        'type',
        'clientName',
        'clientNameLower',
        'dateReceived',
        'createdBy',
        'createdAt',
      ]) {
        expect(after[field], before[field], reason: field);
      }
    });

    test('throws a StateError for an unknown id', () async {
      expect(
        () => repository.updateStatus('nope', TransactionStatus.completed),
        throwsStateError,
      );
    });
  });

  test('a new transaction can be written and read back', () async {
    final transaction = Transaction(
      id: 'ignored',
      type: TransactionType.privateCarOwnershipTransfer,
      clientName: 'فاطمة أحمد',
      status: TransactionStatus.pending,
      dateReceived: DateTime.utc(2024, 7, 1, 12),
      createdBy: 'test-staff-uid',
      createdAt: DateTime.utc(2024, 7, 1, 12),
      updatedAt: DateTime.utc(2024, 7, 1, 12),
    );
    final ref = await transactions().add(
      newTransactionToFirestore(transaction),
    );

    final saved = (await ref.get()).data()!;
    final readBack = (await repository.getTransactions()).single;

    expect(saved['clientNameLower'], 'فاطمه احمد');
    expect(readBack.id, ref.id);
    expect(readBack.clientName, 'فاطمة أحمد');
    expect(readBack.type, TransactionType.privateCarOwnershipTransfer);
    expect(readBack.dateReceived, DateTime.utc(2024, 7, 1, 12));
  });
}
