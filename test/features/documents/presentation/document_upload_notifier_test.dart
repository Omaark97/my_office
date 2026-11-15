import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/documents/data/temporary_document_files.dart';
import 'package:my_office/features/documents/domain/document_files.dart';
import 'package:my_office/features/documents/presentation/document_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../document_fakes.dart';

void main() {
  final pickedAt = DateTime(2026, 11, 15, 10, 30);

  late Directory tempDir;
  late InMemoryTransactionRepository repository;
  late FakeDocumentStorage storage;
  late FakeImageCompressor compressor;
  late FakeDocumentOpener opener;
  late ProviderContainer container;

  ProviderContainer containerFor({String? signedInUid = 'staff-uid'}) {
    return ProviderContainer.test(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        documentStorageProvider.overrideWithValue(storage),
        imageCompressorProvider.overrideWithValue(compressor),
        documentOpenerProvider.overrideWithValue(opener),
        temporaryDocumentFilesProvider.overrideWithValue(
          TemporaryDocumentFiles(baseDirectory: () async => tempDir),
        ),
        currentUserIdProvider.overrideWithValue(signedInUid),
        clockProvider.overrideWithValue(() => pickedAt),
      ],
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('my_office_upload_');
    repository = InMemoryTransactionRepository(clock: () => pickedAt);
    storage = FakeDocumentStorage();
    compressor = FakeImageCompressor();
    opener = FakeDocumentOpener();
    container = containerFor();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  DocumentUploadNotifier uploader() =>
      container.read(documentUploadProvider('test-5').notifier);

  Future<PickedDocumentFile> fileOnDisk(String name, Uint8List bytes) async {
    final file = await File('${tempDir.path}/$name').writeAsBytes(bytes);
    return PickedDocumentFile(path: file.path, name: name);
  }

  PickedDocumentFile photo(String name) =>
      PickedDocumentFile(path: '/photos/$name', name: name);

  group('photos', () {
    test('a photo is compressed, uploaded as JPEG and recorded', () async {
      final added = await uploader().upload([
        photo('IMG_0001.JPG'),
      ], DocumentCategory.saleDeed);

      expect(added, 1);
      expect(compressor.compressedPaths, ['/photos/IMG_0001.JPG']);
      final upload = storage.uploads.single;
      expect(upload.contentType, 'image/jpeg');
      expect(upload.path, startsWith('transactions/test-5/documents/'));
      expect(upload.path, endsWith('.jpg'));

      final saved = (await repository.getDocuments('test-5')).single;
      expect(saved.name, 'Vehicle Sale Deeds 2026-11-15 10.30.jpg');
      expect(saved.mimeType, 'image/jpeg');
      expect(saved.category, DocumentCategory.saleDeed);
      expect(saved.uploadedBy, 'staff-uid');
      expect(saved.storagePath, upload.path);
      expect(saved.sizeBytes, upload.bytes.length);
    });

    test('an iPhone HEIC photo is converted and stored as a JPEG', () async {
      await uploader().upload([
        photo('IMG_0002.HEIC'),
        photo('IMG_0003.heif'),
      ], DocumentCategory.identification);

      expect(compressor.compressedPaths, [
        '/photos/IMG_0002.HEIC',
        '/photos/IMG_0003.heif',
      ]);
      for (final upload in storage.uploads) {
        expect(upload.contentType, 'image/jpeg');
        expect(upload.path, endsWith('.jpg'));
        expect(looksLikeJpeg(upload.bytes), isTrue);
      }
      final names = (await repository.getDocuments(
        'test-5',
      )).map((d) => d.name);
      expect(names, everyElement(endsWith('.jpg')));
    });

    test('if conversion did not produce a JPEG, nothing is uploaded', () async {
      compressor.result = fakeHeicBytes;

      await expectLater(
        uploader().upload([
          photo('IMG_0002.HEIC'),
        ], DocumentCategory.identification),
        throwsA(isA<NotAJpegException>()),
      );
      expect(storage.uploads, isEmpty);
      expect(await repository.getDocuments('test-5'), isEmpty);
    });

    test('several photos are numbered in the order they were picked', () async {
      await uploader().upload([
        photo('a.jpg'),
        photo('b.jpg'),
        photo('c.jpg'),
      ], DocumentCategory.saleDeed);

      final names = (await repository.getDocuments(
        'test-5',
      )).map((d) => d.name);
      expect(names, [
        'Vehicle Sale Deeds 2026-11-15 10.30 (1).jpg',
        'Vehicle Sale Deeds 2026-11-15 10.30 (2).jpg',
        'Vehicle Sale Deeds 2026-11-15 10.30 (3).jpg',
      ]);
    });

    test('a photo over 10 MB after compression is refused', () async {
      compressor.result = fakeJpeg(extraBytes: maxDocumentBytes);

      await expectLater(
        uploader().upload([photo('huge.jpg')], DocumentCategory.other),
        throwsA(isA<DocumentTooLargeException>()),
      );
      expect(storage.uploads, isEmpty);
    });
  });

  group('PDFs', () {
    test('a PDF is uploaded unchanged with its own name', () async {
      final pdf = await fileOnDisk('Notary_POA.pdf', fakePdfBytes);

      await uploader().upload([pdf], DocumentCategory.salePowerOfAttorney);

      expect(compressor.compressedPaths, isEmpty);
      final upload = storage.uploads.single;
      expect(upload.contentType, 'application/pdf');
      expect(upload.path, endsWith('.pdf'));
      expect(upload.bytes, fakePdfBytes);
      final saved = (await repository.getDocuments('test-5')).single;
      expect(saved.name, 'Notary_POA.pdf');
      expect(saved.mimeType, 'application/pdf');
    });

    test('a file named .pdf that is not a PDF is refused', () async {
      final fake = await fileOnDisk('fake.pdf', fakeJpeg());

      await expectLater(
        uploader().upload([fake], DocumentCategory.other),
        throwsA(isA<UnsupportedDocumentException>()),
      );
      expect(storage.uploads, isEmpty);
    });

    test('a PDF over 10 MB is refused', () async {
      final big = await fileOnDisk(
        'big.pdf',
        Uint8List.fromList([
          ...fakePdfBytes,
          ...List.filled(maxDocumentBytes, 0),
        ]),
      );

      await expectLater(
        uploader().upload([big], DocumentCategory.other),
        throwsA(isA<DocumentTooLargeException>()),
      );
      expect(storage.uploads, isEmpty);
    });
  });

  test('an unsupported file type is refused', () async {
    await expectLater(
      uploader().upload([photo('notes.docx')], DocumentCategory.other),
      throwsA(isA<UnsupportedDocumentException>()),
    );
  });

  test('if one file is invalid, none of the batch is uploaded', () async {
    await expectLater(
      uploader().upload([
        photo('good.jpg'),
        photo('bad.gif'),
      ], DocumentCategory.other),
      throwsA(isA<UnsupportedDocumentException>()),
    );
    expect(storage.uploads, isEmpty);
  });

  test('progress is reported per file and cleared at the end', () async {
    final states = <UploadProgress?>[];
    container.listen(
      documentUploadProvider('test-5'),
      (_, next) => states.add(next),
    );

    await uploader().upload([
      photo('a.jpg'),
      photo('b.jpg'),
    ], DocumentCategory.other);

    final progress = states.whereType<UploadProgress>().toList();
    expect(progress.first.current, 1);
    expect(progress.last.current, 2);
    expect(progress.last.total, 2);
    expect(
      progress.map((p) => p.fraction),
      orderedEquals([...progress.map((p) => p.fraction)]..sort()),
    );
    expect(progress.last.fraction, 1);
    expect(states.last, isNull);
  });

  test('a failed upload leaves no record and clears the progress', () async {
    storage.failUploadsWith = Exception('network');

    await expectLater(
      uploader().upload([photo('a.jpg')], DocumentCategory.other),
      throwsException,
    );
    expect(await repository.getDocuments('test-5'), isEmpty);
    expect(container.read(documentUploadProvider('test-5')), isNull);
  });

  test('uploading requires a signed-in user', () async {
    container = containerFor(signedInUid: null);

    await expectLater(
      uploader().upload([photo('a.jpg')], DocumentCategory.other),
      throwsStateError,
    );
  });

  test('the documents list is reloaded after uploading', () async {
    container.listen(transactionDocumentsProvider('test-5'), (_, _) {});
    expect(
      await container.read(transactionDocumentsProvider('test-5').future),
      isEmpty,
    );

    await uploader().upload([photo('a.jpg')], DocumentCategory.other);

    expect(
      await container.read(transactionDocumentsProvider('test-5').future),
      hasLength(1),
    );
  });

  group('opening a PDF', () {
    test('downloads it, writes a temporary copy and opens that copy', () async {
      final pdf = await fileOnDisk('Deed.pdf', fakePdfBytes);
      await uploader().upload([pdf], DocumentCategory.saleDeed);
      final document = (await repository.getDocuments('test-5')).single;

      await container.read(documentOpenControllerProvider).openPdf(document);

      final openedPath = opener.openedPaths.single;
      expect(openedPath, contains('/opened_documents/'));
      expect(await File(openedPath).readAsBytes(), fakePdfBytes);
    });
  });
}
