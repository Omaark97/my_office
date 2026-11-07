/// Where a transaction is in its life.
///
/// Transactions are never deleted: [cancelled] is how a transaction is
/// archived without being completed.
///
/// Each value has a fixed [key] that is saved in the database. Never change
/// an existing key. The [label] is only for display.
enum TransactionStatus {
  pending('pending', 'Pending'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const TransactionStatus(this.key, this.label);

  final String key;
  final String label;

  /// Finds the status saved under [key]. Throws a [FormatException] for an
  /// unknown key.
  static TransactionStatus fromKey(String key) {
    for (final status in values) {
      if (status.key == key) return status;
    }
    throw FormatException('Unknown transaction status: "$key"');
  }
}
