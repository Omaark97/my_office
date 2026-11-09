import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

Transaction _completedTransaction() {
  return Transaction(
    id: 'tx-1',
    type: TransactionType.lienRelease,
    clientName: 'Test User 1',
    clientPhone: '00 000 000',
    status: TransactionStatus.completed,
    dateReceived: DateTime.utc(2024, 4, 15, 12),
    dateCompleted: DateTime.utc(2024, 4, 20, 12),
    createdBy: 'test-staff-uid',
    createdAt: DateTime.utc(2024, 4, 15, 12),
    updatedAt: DateTime.utc(2024, 4, 20, 12),
  );
}

void main() {
  test('toMap saves enums by key and dates as DateTime', () {
    final map = _completedTransaction().toMap();

    expect(map, {
      'type': 'lienRelease',
      'clientName': 'Test User 1',
      'clientPhone': '00 000 000',
      'customerId': null,
      'status': 'completed',
      'dateReceived': DateTime.utc(2024, 4, 15, 12),
      'dateCompleted': DateTime.utc(2024, 4, 20, 12),
      'createdBy': 'test-staff-uid',
      'createdAt': DateTime.utc(2024, 4, 15, 12),
      'updatedAt': DateTime.utc(2024, 4, 20, 12),
    });
    expect(map.containsKey('id'), isFalse);
  });

  test('fromMap(toMap()) gives back the same transaction', () {
    final original = _completedTransaction();

    final copy = Transaction.fromMap(original.id, original.toMap());

    expect(copy.id, 'tx-1');
    expect(copy.toMap(), original.toMap());
  });

  test('optional fields can be null', () {
    final pending = Transaction(
      id: 'tx-2',
      type: TransactionType.other,
      clientName: 'Test User 2',
      status: TransactionStatus.pending,
      dateReceived: DateTime.utc(2024, 6, 1, 12),
      createdBy: 'test-staff-uid',
      createdAt: DateTime.utc(2024, 6, 1, 12),
      updatedAt: DateTime.utc(2024, 6, 1, 12),
    );

    final copy = Transaction.fromMap('tx-2', pending.toMap());

    expect(copy.clientPhone, isNull);
    expect(copy.customerId, isNull);
    expect(copy.dateCompleted, isNull);
  });

  test('dates are always kept in UTC, whatever the input time zone', () {
    final beirutTime = DateTime.parse('2024-05-15T14:00:00+03:00');

    final transaction = Transaction(
      id: 'tx-3',
      type: TransactionType.other,
      clientName: 'Test User 3',
      status: TransactionStatus.pending,
      dateReceived: beirutTime,
      createdBy: 'test-staff-uid',
      createdAt: beirutTime,
      updatedAt: beirutTime.toLocal(),
    );

    expect(transaction.dateReceived.isUtc, isTrue);
    expect(transaction.dateReceived, DateTime.utc(2024, 5, 15, 11));
    expect(transaction.updatedAt, DateTime.utc(2024, 5, 15, 11));
  });

  test('fromMap throws for an unknown type', () {
    final map = _completedTransaction().toMap()..['type'] = 'spaceship';

    expect(() => Transaction.fromMap('tx-1', map), throwsFormatException);
  });

  test('fromMap throws for a missing required field', () {
    final map = _completedTransaction().toMap()..remove('clientName');

    expect(() => Transaction.fromMap('tx-1', map), throwsFormatException);
  });

  test('fromMap throws when a date is a string instead of a DateTime', () {
    final map = _completedTransaction().toMap()
      ..['dateReceived'] = '2024-04-15';

    expect(() => Transaction.fromMap('tx-1', map), throwsFormatException);
  });

  test('copyWith changes only the status fields', () {
    final pending = Transaction.fromMap('tx-1', {
      ..._completedTransaction().toMap(),
      'status': 'pending',
      'dateCompleted': null,
    });
    final now = DateTime.utc(2024, 7, 1, 9);

    final completed = pending.copyWith(
      status: TransactionStatus.completed,
      dateCompleted: now,
      updatedAt: now,
    );

    expect(completed.status, TransactionStatus.completed);
    expect(completed.dateCompleted, now);
    expect(completed.updatedAt, now);
    expect(completed.clientName, pending.clientName);
    expect(completed.dateReceived, pending.dateReceived);
  });
}
