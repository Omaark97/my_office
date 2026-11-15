import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../transactions/domain/archive_access_denied_exception.dart';
import '../domain/document_files.dart';
import '../domain/document_storage.dart';

class FirebaseDocumentStorage implements DocumentStorage {
  FirebaseDocumentStorage({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<StoredFile> upload({
    required String transactionId,
    required String documentId,
    required Uint8List bytes,
    required String contentType,
    required String extension,
    void Function(double fractionSent)? onProgress,
  }) async {
    final path = documentStoragePath(
      transactionId: transactionId,
      documentId: documentId,
      extension: extension,
    );
    try {
      final task = _storage
          .ref(path)
          .putData(bytes, SettableMetadata(contentType: contentType));
      final progress = task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
      try {
        await task;
      } finally {
        await progress.cancel();
      }
      return StoredFile(storagePath: path, sizeBytes: bytes.length);
    } on FirebaseException catch (error) {
      throw storageErrorFrom(error);
    }
  }

  @override
  Future<Uint8List> download(String storagePath) async {
    try {
      final bytes = await _storage.ref(storagePath).getData(maxDocumentBytes);
      if (bytes == null) {
        throw StateError('No file at $storagePath');
      }
      return bytes;
    } on FirebaseException catch (error) {
      throw storageErrorFrom(error);
    }
  }
}

Object storageErrorFrom(FirebaseException error) {
  switch (error.code) {
    case 'unauthorized':
    case 'unauthenticated':
      return const ArchiveAccessDeniedException();
    case 'object-not-found':
      return StateError('File not found: ${error.message}');
    default:
      return error;
  }
}
