import 'client_name_search_key.dart';
import 'phone_number.dart';
import 'transaction_type.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.clientName,
    this.clientPhone,
    required this.dateReceived,
  });

  final TransactionType type;
  final String clientName;
  final String? clientPhone;
  final DateTime dateReceived;

  TransactionDraft cleaned() {
    return TransactionDraft(
      type: type,
      clientName: clientName.trim(),
      clientPhone: normalizePhone(clientPhone),
      dateReceived: dateReceived.toUtc(),
    );
  }
}

bool isValidClientName(String clientName) {
  return clientNameSearchKey(clientName).isNotEmpty;
}
