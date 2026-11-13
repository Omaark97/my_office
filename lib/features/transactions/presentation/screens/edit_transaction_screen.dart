import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/transaction_status.dart';
import '../load_error_message.dart';
import '../transaction_providers.dart';
import 'transaction_form_screen.dart';

class EditTransactionScreen extends ConsumerWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionProvider(transactionId));

    return transaction.when(
      loading: () => const _MessageScaffold(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _MessageScaffold(
        child: Text(
          loadErrorMessage(error, fallback: 'Could not load the transaction'),
          textAlign: TextAlign.center,
        ),
      ),
      data: (transaction) {
        if (transaction == null) {
          return const _MessageScaffold(child: Text('Transaction not found'));
        }
        if (transaction.status != TransactionStatus.pending) {
          return const _MessageScaffold(
            child: Text(
              'Only pending transactions can be edited.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return TransactionFormScreen(
          key: ValueKey(transaction.id),
          initial: transaction,
        );
      },
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
