import 'package:flutter/material.dart';

import '../../../transactions/domain/document_category.dart';
import '../../../transactions/presentation/transaction_icons.dart';

enum DocumentSource { camera, photos, pdf }

Future<DocumentSource?> showDocumentSourceSheet(BuildContext context) {
  return _showSheet<DocumentSource>(
    context,
    title: 'ADD DOCUMENTS',
    options: const [
      (DocumentSource.camera, Icons.photo_camera_outlined, 'Take photo'),
      (DocumentSource.photos, Icons.photo_library_outlined, 'Choose photos'),
      (DocumentSource.pdf, Icons.picture_as_pdf_outlined, 'Choose PDF'),
    ],
  );
}

Future<DocumentCategory?> showDocumentCategorySheet(BuildContext context) {
  return _showSheet<DocumentCategory>(
    context,
    title: 'DOCUMENT CATEGORY',
    options: [
      for (final category in DocumentCategory.values)
        (category, category.icon, category.label),
    ],
  );
}

Future<T?> _showSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, IconData, String)> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final (value, icon, label) in options)
              ListTile(
                leading: Icon(icon, color: Colors.teal),
                title: Text(label),
                onTap: () => Navigator.of(sheetContext).pop(value),
              ),
          ],
        ),
      ),
    ),
  );
}
