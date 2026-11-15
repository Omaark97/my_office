import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/app/app.dart';
import 'package:my_office/app/router.dart';
import 'package:my_office/app/routes.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/documents/data/temporary_document_files.dart';
import 'package:my_office/features/documents/domain/document_files.dart';
import 'package:my_office/features/documents/domain/document_storage.dart';
import 'package:my_office/features/documents/presentation/document_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/new_document.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../../auth/fake_auth_repository.dart';
import '../../../test_helpers.dart';
import '../document_fakes.dart';

final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

class _HeldStorage extends FakeDocumentStorage {
  final release = Completer<void>();

  @override
  Future<StoredFile> upload({
    required String transactionId,
    required String documentId,
    required Uint8List bytes,
    required String contentType,
    required String extension,
    void Function(double fractionSent)? onProgress,
  }) async {
    onProgress?.call(0.4);
    await release.future;
    return super.upload(
      transactionId: transactionId,
      documentId: documentId,
      bytes: bytes,
      contentType: contentType,
      extension: extension,
      onProgress: onProgress,
    );
  }
}

class _Harness {
  _Harness({FakeDocumentStorage? storage})
    : storage = storage ?? FakeDocumentStorage();

  final repository = InMemoryTransactionRepository(
    clock: () => DateTime.utc(2026, 11, 15, 8),
  );
  final FakeDocumentStorage storage;
  final picker = FakeDocumentPicker();
  final opener = FakeDocumentOpener();
  late Directory tempDir;
  late ProviderContainer container;

  Future<void> openTransaction(WidgetTester tester, String id) async {
    useIPhoneScreen(tester);
    tempDir = Directory.systemTemp.createTempSync('my_office_ui_');
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedInUser: testUser),
        ),
        transactionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15, 10, 30)),
        documentStorageProvider.overrideWithValue(storage),
        imageCompressorProvider.overrideWithValue(FakeImageCompressor()),
        documentPickerProvider.overrideWithValue(picker),
        documentOpenerProvider.overrideWithValue(opener),
        temporaryDocumentFilesProvider.overrideWithValue(
          TemporaryDocumentFiles(baseDirectory: () async => tempDir),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).push(AppRoutes.transaction(id));
    await tester.pumpAndSettle();
  }

  Future<void> addStoredDocument(
    String transactionId,
    String name,
    String mimeType,
    Uint8List bytes,
  ) async {
    final id = repository.newDocumentId(transactionId);
    final extension = mimeType == pdfMimeType ? 'pdf' : 'png';
    final path = documentStoragePath(
      transactionId: transactionId,
      documentId: id,
      extension: extension,
    );
    storage.files[path] = bytes;
    await repository.addDocument(
      transactionId,
      id,
      NewDocument(
        name: name,
        mimeType: mimeType,
        sizeBytes: bytes.length,
        category: DocumentCategory.other,
        storagePath: path,
      ),
      uploadedBy: 'test-staff-uid',
    );
  }
}

Finder get _uploadZone => find.text('Add Supporting Documents');

Future<void> _tapUploadZone(WidgetTester tester) async {
  await tester.ensureVisible(_uploadZone);
  await tester.tap(_uploadZone);
  await tester.pumpAndSettle();
}

Future<void> _chooseSourceAndCategory(
  WidgetTester tester,
  String source,
  String category,
) async {
  await _tapUploadZone(tester);
  await tester.tap(find.text(source));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category).last);
  await tester.pumpAndSettle();
}

PickedDocumentFile _photo(String name) =>
    PickedDocumentFile(path: '/photos/$name', name: name);

void main() {
  group('upload zone', () {
    testWidgets('is shown for pending and completed transactions', (
      tester,
    ) async {
      final harness = _Harness();
      await harness.openTransaction(tester, 'test-5');
      expect(_uploadZone, findsOneWidget);

      await harness.openTransaction(tester, 'test-1');
      expect(_uploadZone, findsOneWidget);
    });

    testWidgets('is hidden for a cancelled transaction', (tester) async {
      final harness = _Harness();
      await harness.repository.updateStatus(
        'test-4',
        TransactionStatus.cancelled,
      );

      await harness.openTransaction(tester, 'test-4');

      expect(_uploadZone, findsNothing);
    });

    testWidgets('offers camera, photos and PDF', (tester) async {
      final harness = _Harness();
      await harness.openTransaction(tester, 'test-5');

      await _tapUploadZone(tester);

      expect(find.text('ADD DOCUMENTS'), findsOneWidget);
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose photos'), findsOneWidget);
      expect(find.text('Choose PDF'), findsOneWidget);
    });
  });

  testWidgets('choosing several photos adds them numbered in order', (
    tester,
  ) async {
    final harness = _Harness();
    harness.picker.photos = [_photo('IMG_1.HEIC'), _photo('IMG_2.HEIC')];
    await harness.openTransaction(tester, 'test-5');

    await _chooseSourceAndCategory(
      tester,
      'Choose photos',
      'Vehicle Sale Deeds',
    );

    expect(find.text('2 documents added'), findsOneWidget);
    expect(
      find.text('Vehicle Sale Deeds 2026-11-15 10.30 (1).jpg'),
      findsOneWidget,
    );
    expect(
      find.text('Vehicle Sale Deeds 2026-11-15 10.30 (2).jpg'),
      findsOneWidget,
    );
    expect(find.text('2 files'), findsOneWidget);
    expect(harness.storage.uploads, hasLength(2));
  });

  testWidgets('a single camera photo says "Document added"', (tester) async {
    final harness = _Harness();
    harness.picker.camera = [_photo('camera.jpg')];
    await harness.openTransaction(tester, 'test-5');

    await _chooseSourceAndCategory(
      tester,
      'Take photo',
      'Identification Documents',
    );

    expect(find.text('Document added'), findsOneWidget);
    expect(find.text('1 file'), findsOneWidget);
  });

  testWidgets('cancelling the picker adds nothing', (tester) async {
    final harness = _Harness();
    await harness.openTransaction(tester, 'test-5');

    await _tapUploadZone(tester);
    await tester.tap(find.text('Choose photos'));
    await tester.pumpAndSettle();

    expect(find.text('DOCUMENT CATEGORY'), findsNothing);
    expect(harness.storage.uploads, isEmpty);
  });

  testWidgets('shows progress while uploading', (tester) async {
    final storage = _HeldStorage();
    final harness = _Harness(storage: storage);
    harness.picker.camera = [_photo('camera.jpg')];
    await harness.openTransaction(tester, 'test-5');

    await _tapUploadZone(tester);
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pump();
    await tester.pump();

    expect(find.text('Uploading 1 of 1…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(_uploadZone, findsNothing);

    storage.release.complete();
    await tester.pumpAndSettle();
    expect(find.text('Uploading 1 of 1…'), findsNothing);
    expect(_uploadZone, findsOneWidget);
  });

  testWidgets('an unsupported file shows a clear message', (tester) async {
    final harness = _Harness();
    harness.picker.photos = [_photo('animation.gif')];
    await harness.openTransaction(tester, 'test-5');

    await _chooseSourceAndCategory(tester, 'Choose photos', 'Other');

    expect(
      find.text('Only photos (JPEG, PNG, HEIC) and PDF files can be added.'),
      findsOneWidget,
    );
    expect(harness.storage.uploads, isEmpty);
  });

  testWidgets('tapping an image opens it full screen', (tester) async {
    final harness = _Harness();
    await harness.addStoredDocument(
      'test-5',
      'Scan.png',
      'image/png',
      Uint8List.fromList(_onePixelPng),
    );
    await harness.openTransaction(tester, 'test-5');

    await tester.tap(find.text('Scan.png'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Scan.png'), findsOneWidget);
  });

  testWidgets('tapping a PDF opens a temporary copy in the system viewer', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.addStoredDocument(
      'test-5',
      'Deed.pdf',
      pdfMimeType,
      fakePdfBytes,
    );
    await harness.openTransaction(tester, 'test-5');

    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Open Deed.pdf'));
      for (var i = 0; i < 50 && harness.opener.openedPaths.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    final opened = harness.opener.openedPaths.single;
    expect(opened, contains('/opened_documents/'));
    expect(File(opened).readAsBytesSync(), fakePdfBytes);
  });

  testWidgets('the category gallery no longer loads web images', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.openTransaction(tester, 'test-5');

    harness.container
        .read(routerProvider)
        .push(AppRoutes.gallery('Vehicle Sale Deeds'));
    await tester.pumpAndSettle();

    expect(find.text('Vehicle Sale Deeds'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
