enum TransactionStatus {
  pending('pending', 'Pending'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const TransactionStatus(this.key, this.label);

  final String key;
  final String label;

  static TransactionStatus fromKey(String key) {
    for (final status in values) {
      if (status.key == key) return status;
    }
    throw FormatException('Unknown transaction status: "$key"');
  }
}
