import 'dart:typed_data';

import 'package:my_office/features/documents/data/document_opener.dart';
import 'package:my_office/features/documents/data/document_picker.dart';
import 'package:my_office/features/documents/data/image_compressor.dart';
import 'package:my_office/features/documents/domain/document_files.dart';
import 'package:my_office/features/documents/domain/document_storage.dart';

Uint8List fakeJpeg({int extraBytes = 100}) {
  return Uint8List.fromList([
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    ...List.filled(extraBytes, 0),
    0xFF,
    0xD9,
  ]);
}

final fakeHeicBytes = Uint8List.fromList([
  0x00,
  0x00,
  0x00,
  0x18,
  0x66,
  0x74,
  0x79,
  0x70,
  0x68,
  0x65,
  0x69,
  0x63,
]);

final fakePdfBytes = Uint8List.fromList('%PDF-1.7 fake'.codeUnits);

class UploadedFile {
  const UploadedFile({
    required this.path,
    required this.contentType,
    required this.bytes,
  });

  final String path;
  final String contentType;
  final Uint8List bytes;
}

class FakeDocumentStorage implements DocumentStorage {
  final uploads = <UploadedFile>[];
  final files = <String, Uint8List>{};
  Object? failUploadsWith;

  @override
  Future<StoredFile> upload({
    required String transactionId,
    required String documentId,
    required Uint8List bytes,
    required String contentType,
    required String extension,
    void Function(double fractionSent)? onProgress,
  }) async {
    final failure = failUploadsWith;
    if (failure != null) throw failure;
    final path = documentStoragePath(
      transactionId: transactionId,
      documentId: documentId,
      extension: extension,
    );
    onProgress?.call(0.5);
    onProgress?.call(1);
    uploads.add(
      UploadedFile(path: path, contentType: contentType, bytes: bytes),
    );
    files[path] = bytes;
    return StoredFile(storagePath: path, sizeBytes: bytes.length);
  }

  @override
  Future<Uint8List> download(String storagePath) async {
    final bytes = files[storagePath];
    if (bytes == null) throw StateError('No file at $storagePath');
    return bytes;
  }
}

class FakeImageCompressor implements ImageCompressor {
  FakeImageCompressor({Uint8List? result}) : result = result ?? fakeJpeg();

  Uint8List result;
  final compressedPaths = <String>[];

  @override
  Future<Uint8List> toArchiveJpeg(String imagePath) async {
    compressedPaths.add(imagePath);
    return result;
  }
}

class FakeDocumentPicker implements DocumentPicker {
  List<PickedDocumentFile> camera = const [];
  List<PickedDocumentFile> photos = const [];
  List<PickedDocumentFile> pdf = const [];

  @override
  Future<List<PickedDocumentFile>> takePhoto() async => camera;

  @override
  Future<List<PickedDocumentFile>> choosePhotos() async => photos;

  @override
  Future<List<PickedDocumentFile>> choosePdf() async => pdf;
}

class FakeDocumentOpener implements DocumentOpener {
  final openedPaths = <String>[];

  @override
  Future<void> openPdf(String filePath) async {
    openedPaths.add(filePath);
  }
}
