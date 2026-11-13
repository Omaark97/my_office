import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/transaction.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';
import 'package:my_office/features/transactions/presentation/transaction_status_style.dart';

Transaction _transaction(TransactionStatus status, {DateTime? dateCompleted}) {
  return Transaction(
    id: 'tx-1',
    type: TransactionType.other,
    clientName: 'Test User 1',
    status: status,
    dateReceived: DateTime.utc(2024, 5, 15, 12),
    dateCompleted: dateCompleted,
    createdBy: 'test-staff-uid',
    createdAt: DateTime.utc(2024, 5, 15, 12),
    updatedAt: DateTime.utc(2024, 5, 20, 12),
  );
}

void main() {
  group('statusLine', () {
    test('pending shows the received date', () {
      expect(
        statusLine(_transaction(TransactionStatus.pending)),
        'Pending since 2024-05-15',
      );
    });

    test('completed shows the completed date', () {
      expect(
        statusLine(
          _transaction(
            TransactionStatus.completed,
            dateCompleted: DateTime.utc(2024, 5, 18, 12),
          ),
        ),
        'Completed on 2024-05-18',
      );
    });

    test('cancelled shows the date it was last changed', () {
      expect(
        statusLine(_transaction(TransactionStatus.cancelled)),
        'Cancelled on 2024-05-20',
      );
    });
  });

  test('each status has its own icon and colour', () {
    expect(TransactionStatus.pending.icon, Icons.hourglass_empty);
    expect(TransactionStatus.completed.icon, Icons.check_circle);
    expect(TransactionStatus.cancelled.icon, Icons.cancel);
    expect(TransactionStatus.cancelled.iconColor, Colors.grey);
    expect(TransactionStatus.cancelled.badgeText, Colors.grey.shade700);
  });
}
