import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../transactions/domain/transaction_document.dart';
import '../data/document_picker.dart';
import '../domain/document_files.dart';
import 'document_error_message.dart';
import 'document_providers.dart';
import 'widgets/document_sheets.dart';

Future<void> addDocumentsTo(
  BuildContext context,
  WidgetRef ref,
  String transactionId,
) async {
  final source = await showDocumentSourceSheet(context);
  if (source == null || !context.mounted) return;

  final picker = ref.read(documentPickerProvider);
  try {
    final files = await _pickFiles(picker, source);
    if (files.isEmpty || !context.mounted) return;

    final category = await showDocumentCategorySheet(context);
    if (category == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final added = await ref
          .read(documentUploadProvider(transactionId).notifier)
          .upload(files, category);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            added == 1 ? 'Document added' : '$added documents added',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            documentErrorMessage(
              error,
              fallback: 'Could not add the document. Please try again.',
            ),
          ),
        ),
      );
    }
  } finally {
    if (source == DocumentSource.scan) {
      await picker.clearScannedPages().catchError((Object _) {});
    }
  }
}

Future<List<PickedDocumentFile>> _pickFiles(
  DocumentPicker picker,
  DocumentSource source,
) {
  switch (source) {
    case DocumentSource.scan:
      return picker.scanDocument();
    case DocumentSource.camera:
      return picker.takePhoto();
    case DocumentSource.photos:
      return picker.choosePhotos();
    case DocumentSource.pdf:
      return picker.choosePdf();
  }
}

Future<void> openDocument(
  BuildContext context,
  WidgetRef ref,
  String transactionId,
  TransactionDocument document,
) async {
  if (!document.isPdf) {
    await context.push(AppRoutes.documentViewer(transactionId, document.id));
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text('Opening ${document.name}…')));
  try {
    await ref.read(documentOpenControllerProvider).openPdf(document);
    messenger.hideCurrentSnackBar();
  } catch (error) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          documentErrorMessage(
            error,
            fallback: 'Could not open the document. Please try again.',
          ),
        ),
      ),
    );
  }
}
