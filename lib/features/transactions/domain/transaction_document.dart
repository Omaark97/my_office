import 'document_category.dart';
import 'map_reading.dart';

/// A scanned document (image or PDF) attached to a transaction.
///
/// Only the details are stored here. The file itself lives in file storage
/// at [storagePath].
class TransactionDocument {
  TransactionDocument({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.category,
    required DateTime uploadedAt,
    required this.uploadedBy,
    required this.storagePath,
  }) : uploadedAt = uploadedAt.toUtc();

  /// The database document id. It is not stored inside [toMap].
  final String id;

  /// The file name shown to the user, for example "ID_Front.jpg".
  final String name;

  /// For example "image/jpeg" or "application/pdf".
  final String mimeType;
  final int sizeBytes;
  final DocumentCategory category;

  /// Kept in UTC.
  final DateTime uploadedAt;

  /// The uid of the staff member who uploaded it.
  final String uploadedBy;

  /// Where the file is, for example "transactions/abc/documents/xyz.jpg".
  /// Never a download link.
  final String storagePath;

  bool get isPdf => mimeType == 'application/pdf';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'category': category.key,
      'uploadedAt': uploadedAt,
      'uploadedBy': uploadedBy,
      'storagePath': storagePath,
    };
  }

  /// Rebuilds a document from saved fields. Throws a [FormatException] if a
  /// field is missing or invalid.
  factory TransactionDocument.fromMap(String id, Map<String, dynamic> map) {
    return TransactionDocument(
      id: id,
      name: readString(map, 'name'),
      mimeType: readString(map, 'mimeType'),
      sizeBytes: readInt(map, 'sizeBytes'),
      category: DocumentCategory.fromKey(readString(map, 'category')),
      uploadedAt: readDate(map, 'uploadedAt'),
      uploadedBy: readString(map, 'uploadedBy'),
      storagePath: readString(map, 'storagePath'),
    );
  }
}
