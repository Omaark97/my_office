import 'package:flutter/material.dart';

import '../domain/transaction.dart';
import '../domain/transaction_status.dart';
import 'formatters.dart';

extension TransactionStatusStyle on TransactionStatus {
  IconData get icon {
    switch (this) {
      case TransactionStatus.pending:
        return Icons.hourglass_empty;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color get iconColor {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  Color get badgeBackground {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange.shade50;
      case TransactionStatus.completed:
        return Colors.green.shade50;
      case TransactionStatus.cancelled:
        return Colors.grey.shade200;
    }
  }

  Color get badgeText {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange.shade700;
      case TransactionStatus.completed:
        return Colors.green.shade700;
      case TransactionStatus.cancelled:
        return Colors.grey.shade700;
    }
  }
}

String statusLine(Transaction transaction) {
  switch (transaction.status) {
    case TransactionStatus.pending:
      return 'Pending since ${formatDate(transaction.dateReceived)}';
    case TransactionStatus.completed:
      final completedOn = transaction.dateCompleted ?? transaction.updatedAt;
      return 'Completed on ${formatDate(completedOn)}';
    case TransactionStatus.cancelled:
      return 'Cancelled on ${formatDate(transaction.updatedAt)}';
  }
}
