import 'document_category.dart';
import 'map_reading.dart';

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

  final String id;

  final String name;

  final String mimeType;
  final int sizeBytes;
  final DocumentCategory category;

  final DateTime uploadedAt;

  final String uploadedBy;

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
