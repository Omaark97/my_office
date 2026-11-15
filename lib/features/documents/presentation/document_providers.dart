import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../transactions/domain/document_category.dart';
import '../../transactions/domain/new_document.dart';
import '../../transactions/domain/transaction_document.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../data/document_opener.dart';
import '../data/document_picker.dart';
import '../data/document_sharer.dart';
import '../data/firebase_document_storage.dart';
import '../data/image_compressor.dart';
import '../data/printable_pdf.dart';
import '../data/temporary_document_files.dart';
import '../domain/document_files.dart';
import '../domain/document_storage.dart';
import '../domain/hidden_share_action.dart';

final documentStorageProvider = Provider<DocumentStorage>(
  (ref) => FirebaseDocumentStorage(),
);

final imageCompressorProvider = Provider<ImageCompressor>(
  (ref) => NativeImageCompressor(),
);

final documentPickerProvider = Provider<DocumentPicker>(
  (ref) => PluginDocumentPicker(),
);

final temporaryDocumentFilesProvider = Provider<TemporaryDocumentFiles>(
  (ref) => TemporaryDocumentFiles(),
);

final documentOpenerProvider = Provider<DocumentOpener>(
  (ref) => SystemDocumentOpener(),
);

final documentSharerProvider = Provider<DocumentSharer>(
  (ref) => SystemDocumentSharer(),
);

final documentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>(
      (ref, storagePath) =>
          ref.watch(documentStorageProvider).download(storagePath),
    );

class UploadProgress {
  const UploadProgress({
    required this.current,
    required this.total,
    required this.fraction,
  });

  final int current;
  final int total;
  final double fraction;
}

final documentUploadProvider =
    NotifierProvider.family<DocumentUploadNotifier, UploadProgress?, String>(
      DocumentUploadNotifier.new,
    );

class DocumentUploadNotifier extends Notifier<UploadProgress?> {
  DocumentUploadNotifier(this.transactionId);

  final String transactionId;

  @override
  UploadProgress? build() => null;

  Future<int> upload(
    List<PickedDocumentFile> files,
    DocumentCategory category,
  ) async {
    if (files.isEmpty) return 0;
    if (state != null) {
      throw StateError('An upload is already running');
    }
    final uploadedBy = ref.read(currentUserIdProvider);
    if (uploadedBy == null) {
      throw StateError('Sign in before adding documents');
    }
    final pickedAt = ref.read(clockProvider)();
    final total = files.length;
    state = UploadProgress(current: 1, total: total, fraction: 0);
    try {
      final prepared = [
        for (var index = 0; index < total; index++)
          await _prepare(
            files[index],
            category,
            pickedAt,
            pageNumber: total > 1 ? index + 1 : null,
          ),
      ];
      final repository = ref.read(transactionRepositoryProvider);
      final storage = ref.read(documentStorageProvider);
      for (var index = 0; index < total; index++) {
        final document = prepared[index];
        final documentId = repository.newDocumentId(transactionId);
        final stored = await storage.upload(
          transactionId: transactionId,
          documentId: documentId,
          bytes: document.bytes,
          contentType: document.mimeType,
          extension: document.extension,
          onProgress: (sent) {
            if (!ref.mounted) return;
            state = UploadProgress(
              current: index + 1,
              total: total,
              fraction: (index + sent) / total,
            );
          },
        );
        await repository.addDocument(
          transactionId,
          documentId,
          NewDocument(
            name: document.name,
            mimeType: document.mimeType,
            sizeBytes: stored.sizeBytes,
            category: category,
            storagePath: stored.storagePath,
          ),
          uploadedBy: uploadedBy,
        );
      }
      return total;
    } finally {
      if (ref.mounted) {
        state = null;
        ref.invalidate(transactionDocumentsProvider(transactionId));
      }
    }
  }

  Future<_PreparedDocument> _prepare(
    PickedDocumentFile file,
    DocumentCategory category,
    DateTime pickedAt, {
    int? pageNumber,
  }) async {
    switch (file.kind) {
      case PickedFileKind.unsupported:
        throw UnsupportedDocumentException(file.name);
      case PickedFileKind.pdf:
        final bytes = await File(file.path).readAsBytes();
        if (!looksLikePdf(bytes)) {
          throw UnsupportedDocumentException(file.name);
        }
        return _checked(
          _PreparedDocument(
            name: pdfDocumentName(file.name),
            mimeType: pdfMimeType,
            extension: 'pdf',
            bytes: bytes,
          ),
        );
      case PickedFileKind.image:
        final bytes = await ref
            .read(imageCompressorProvider)
            .toArchiveJpeg(file.path);
        if (!looksLikeJpeg(bytes)) {
          throw NotAJpegException(file.name);
        }
        return _checked(
          _PreparedDocument(
            name: photoDocumentName(category, pickedAt, pageNumber: pageNumber),
            mimeType: jpegMimeType,
            extension: 'jpg',
            bytes: bytes,
          ),
        );
    }
  }

  _PreparedDocument _checked(_PreparedDocument document) {
    if (document.bytes.length > maxDocumentBytes) {
      throw DocumentTooLargeException(document.name, document.bytes.length);
    }
    return document;
  }
}

class _PreparedDocument {
  const _PreparedDocument({
    required this.name,
    required this.mimeType,
    required this.extension,
    required this.bytes,
  });

  final String name;
  final String mimeType;
  final String extension;
  final Uint8List bytes;
}

final documentOpenControllerProvider = Provider<DocumentOpenController>(
  DocumentOpenController.new,
);

class DocumentOpenController {
  DocumentOpenController(this._ref);

  final Ref _ref;

  Future<void> openPdf(TransactionDocument document) async {
    final bytes = await _ref
        .read(documentStorageProvider)
        .download(document.storagePath);
    final copy = await _ref
        .read(temporaryDocumentFilesProvider)
        .writeForViewing(
          documentId: document.id,
          extension: 'pdf',
          bytes: bytes,
        );
    await _ref.read(documentOpenerProvider).openPdf(copy.path);
  }
}

final documentShareControllerProvider = Provider<DocumentShareController>(
  DocumentShareController.new,
);

class DocumentShareController {
  DocumentShareController(this._ref);

  final Ref _ref;

  Future<void> share(TransactionDocument document) async {
    final bytes = await _ref
        .read(documentStorageProvider)
        .download(document.storagePath);
    final printable = document.isPdf
        ? bytes
        : await imageAsPrintablePdf(bytes, title: document.name);
    final copy = await _ref
        .read(temporaryDocumentFilesProvider)
        .writeForSharing(
          fileName: shareFileName(document.name, asPdf: true),
          bytes: printable,
        );
    try {
      await _ref
          .read(documentSharerProvider)
          .shareFile(
            copy.path,
            mimeType: pdfMimeType,
            hiddenActions: clientDocumentHiddenShareActions,
          );
    } finally {
      if (await copy.exists()) await copy.delete();
    }
  }
}
