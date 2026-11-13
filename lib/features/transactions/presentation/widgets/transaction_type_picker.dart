import 'package:flutter/material.dart';

import '../../domain/transaction_type.dart';
import '../transaction_icons.dart';

Future<TransactionType?> showTransactionTypePicker(
  BuildContext context, {
  TransactionType? selected,
}) {
  return showModalBottomSheet<TransactionType>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'TRANSACTION TYPE',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final type in TransactionType.values)
              ListTile(
                leading: Icon(type.icon, color: Colors.teal),
                title: Text(type.label),
                trailing: type == selected
                    ? const Icon(Icons.check, color: Colors.teal)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(type),
              ),
          ],
        ),
      ),
    ),
  );
}
