import 'map_reading.dart';
import 'transaction_status.dart';
import 'transaction_type.dart';

/// One piece of work the office does for a client, such as an ownership
/// transfer.
///
/// All dates are kept in UTC (the constructor converts them). Screens convert
/// them to the phone's local time only when showing them.
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

  /// The database document id. It is not stored inside [toMap].
  final String id;
  final TransactionType type;

  /// The client's name as typed. May be Arabic or English.
  final String clientName;
  final String? clientPhone;

  /// Links to the future customer app. Always null for now.
  final String? customerId;
  final TransactionStatus status;
  final DateTime dateReceived;

  /// Set when the transaction is completed.
  final DateTime? dateCompleted;

  /// The uid of the staff member who created it.
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Returns a copy with a new status. Used by the status-change methods.
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

  /// The fields to save. Enums are saved by their fixed key.
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

  /// Rebuilds a transaction from saved fields. Throws a [FormatException] if
  /// a field is missing or invalid.
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
