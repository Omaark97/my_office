import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/transaction_document.dart';

TransactionDocument _document() {
  return TransactionDocument(
    id: 'doc-1',
    name: 'ID_Front.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1258291,
    category: DocumentCategory.identification,
    uploadedAt: DateTime.utc(2024, 5, 15, 12),
    uploadedBy: 'test-staff-uid',
    storagePath: 'transactions/tx-1/documents/doc-1.jpg',
  );
}

void main() {
  test('toMap saves the category by key', () {
    expect(_document().toMap(), {
      'name': 'ID_Front.jpg',
      'mimeType': 'image/jpeg',
      'sizeBytes': 1258291,
      'category': 'identification',
      'uploadedAt': DateTime.utc(2024, 5, 15, 12),
      'uploadedBy': 'test-staff-uid',
      'storagePath': 'transactions/tx-1/documents/doc-1.jpg',
    });
  });

  test('fromMap(toMap()) gives back the same document', () {
    final original = _document();

    final copy = TransactionDocument.fromMap('doc-1', original.toMap());

    expect(copy.id, 'doc-1');
    expect(copy.toMap(), original.toMap());
  });

  test('uploadedAt is kept in UTC', () {
    final document = TransactionDocument.fromMap('doc-1', {
      ..._document().toMap(),
      'uploadedAt': DateTime.parse('2024-05-15T15:00:00+03:00'),
    });

    expect(document.uploadedAt.isUtc, isTrue);
    expect(document.uploadedAt, DateTime.utc(2024, 5, 15, 12));
  });

  test('isPdf is based on the mime type', () {
    expect(_document().isPdf, isFalse);

    final pdf = TransactionDocument.fromMap('doc-2', {
      ..._document().toMap(),
      'mimeType': 'application/pdf',
    });
    expect(pdf.isPdf, isTrue);
  });

  test('fromMap throws for an unknown category', () {
    final map = _document().toMap()..['category'] = 'photo';

    expect(
      () => TransactionDocument.fromMap('doc-1', map),
      throwsFormatException,
    );
  });

  test('fromMap throws when sizeBytes is not a whole number', () {
    final map = _document().toMap()..['sizeBytes'] = '1.2 MB';

    expect(
      () => TransactionDocument.fromMap('doc-1', map),
      throwsFormatException,
    );
  });
}
