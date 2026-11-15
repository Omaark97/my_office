import 'dart:typed_data';

class StoredFile {
  const StoredFile({required this.storagePath, required this.sizeBytes});

  final String storagePath;
  final int sizeBytes;
}

abstract class DocumentStorage {
  Future<StoredFile> upload({
    required String transactionId,
    required String documentId,
    required Uint8List bytes,
    required String contentType,
    required String extension,
    void Function(double fractionSent)? onProgress,
  });

  Future<Uint8List> download(String storagePath);
}

String documentStoragePath({
  required String transactionId,
  required String documentId,
  required String extension,
}) {
  return 'transactions/$transactionId/documents/$documentId.$extension';
}
