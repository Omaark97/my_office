import 'map_reading.dart';
import 'transaction_status.dart';
import 'transaction_type.dart';

class Transaction {
  Transaction({
    required this.id,
    required this.type,
    required this.clientName,
    this.clientPhone,
    this.customerId,
    required this.status,
    required DateTime dateReceived,
    DateTime? dateCompleted,
    required this.createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : dateReceived = dateReceived.toUtc(),
       dateCompleted = dateCompleted?.toUtc(),
       createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc();

  final String id;
  final TransactionType type;

  final String clientName;
  final String? clientPhone;

  final String? customerId;
  final TransactionStatus status;
  final DateTime dateReceived;

  final DateTime? dateCompleted;

  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction copyWith({
    TransactionStatus? status,
    DateTime? dateCompleted,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id,
      type: type,
      clientName: clientName,
      clientPhone: clientPhone,
      customerId: customerId,
      status: status ?? this.status,
      dateReceived: dateReceived,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.key,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'customerId': customerId,
      'status': status.key,
      'dateReceived': dateReceived,
      'dateCompleted': dateCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Transaction.fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      type: TransactionType.fromKey(readString(map, 'type')),
      clientName: readString(map, 'clientName'),
      clientPhone: readOptionalString(map, 'clientPhone'),
      customerId: readOptionalString(map, 'customerId'),
      status: TransactionStatus.fromKey(readString(map, 'status')),
      dateReceived: readDate(map, 'dateReceived'),
      dateCompleted: readOptionalDate(map, 'dateCompleted'),
      createdBy: readString(map, 'createdBy'),
      createdAt: readDate(map, 'createdAt'),
      updatedAt: readDate(map, 'updatedAt'),
    );
  }
}
