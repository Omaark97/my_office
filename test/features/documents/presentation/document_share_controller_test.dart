import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:my_office/features/documents/data/temporary_document_files.dart';
import 'package:my_office/features/documents/domain/document_files.dart';
import 'package:my_office/features/documents/domain/hidden_share_action.dart';
import 'package:my_office/features/documents/presentation/document_providers.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/transaction_document.dart';

import '../document_fakes.dart';

void main() {
  late Directory tempDir;
  late FakeDocumentStorage storage;
  late FakeDocumentSharer sharer;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('my_office_share_');
    storage = FakeDocumentStorage();
    sharer = FakeDocumentSharer();
    container = ProviderContainer.test(
      overrides: [
        documentStorageProvider.overrideWithValue(storage),
        documentSharerProvider.overrideWithValue(sharer),
        temporaryDocumentFilesProvider.overrideWithValue(
          TemporaryDocumentFiles(baseDirectory: () async => tempDir),
        ),
      ],
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  TransactionDocument storedDocument(
    String name,
    String mimeType,
    Uint8List bytes,
  ) {
    final path = 'transactions/tx-1/documents/${name.hashCode}';
    storage.files[path] = bytes;
    return TransactionDocument(
      id: 'doc-${name.hashCode}',
      name: name,
      mimeType: mimeType,
      sizeBytes: bytes.length,
      category: DocumentCategory.saleDeed,
      uploadedAt: DateTime.utc(2026, 11, 15),
      uploadedBy: 'staff-uid',
      storagePath: path,
    );
  }

  Future<void> share(TransactionDocument document) =>
      container.read(documentShareControllerProvider).share(document);

  final photo = img.encodeJpg(img.Image(width: 30, height: 40));

  test('an image is shared as a printable PDF named after it', () async {
    await share(
      storedDocument(
        'Vehicle Sale Deeds 2026-11-15 10.30 (1).jpg',
        'image/jpeg',
        photo,
      ),
    );

    final shared = sharer.shared.single;
    expect(shared.mimeType, 'application/pdf');
    expect(
      shared.path,
      endsWith('/Vehicle Sale Deeds 2026-11-15 10.30 (1).pdf'),
    );
    expect(looksLikePdf(shared.bytesAtShareTime), isTrue);
  });

  test('a PDF is shared unchanged', () async {
    await share(
      storedDocument('Notary_POA.pdf', 'application/pdf', fakePdfBytes),
    );

    final shared = sharer.shared.single;
    expect(shared.path, endsWith('/Notary_POA.pdf'));
    expect(shared.bytesAtShareTime, fakePdfBytes);
  });

  test('Save to Photos, Copy and Assign to Contact are hidden', () async {
    await share(storedDocument('Deed.pdf', 'application/pdf', fakePdfBytes));

    expect(sharer.shared.single.hiddenActions, [
      HiddenShareAction.saveToPhotos,
      HiddenShareAction.copy,
      HiddenShareAction.assignToContact,
    ]);
  });

  test('the temporary copy is deleted after sharing', () async {
    await share(storedDocument('Deed.pdf', 'application/pdf', fakePdfBytes));

    expect(File(sharer.shared.single.path).existsSync(), isFalse);
  });

  test('the temporary copy is deleted even when sharing fails', () async {
    sharer.failWith = Exception('share sheet failed');

    await expectLater(
      share(storedDocument('Deed.pdf', 'application/pdf', fakePdfBytes)),
      throwsException,
    );
    expect(File(sharer.shared.single.path).existsSync(), isFalse);
  });
}
