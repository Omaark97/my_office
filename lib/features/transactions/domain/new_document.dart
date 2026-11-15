import 'document_category.dart';

class NewDocument {
  const NewDocument({
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.category,
    required this.storagePath,
  });

  final String name;
  final String mimeType;
  final int sizeBytes;
  final DocumentCategory category;
  final String storagePath;
}
