import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/documents/data/temporary_document_files.dart';

void main() {
  late Directory base;
  late TemporaryDocumentFiles files;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('my_office_test_');
    files = TemporaryDocumentFiles(baseDirectory: () async => base);
  });

  tearDown(() async {
    if (await base.exists()) await base.delete(recursive: true);
  });

  Directory openedFolder() =>
      Directory('${base.path}/${TemporaryDocumentFiles.folderName}');

  test('writes a copy for viewing', () async {
    final file = await files.writeForViewing(
      documentId: 'doc-1',
      extension: 'pdf',
      bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
    );

    expect(await file.exists(), isTrue);
    expect(file.path, endsWith('/opened_documents/doc-1.pdf'));
    expect(await file.readAsString(), '%PDF-1.7');
  });

  test('opening another document deletes the previous copy', () async {
    final first = await files.writeForViewing(
      documentId: 'doc-1',
      extension: 'pdf',
      bytes: Uint8List.fromList([1]),
    );

    await files.writeForViewing(
      documentId: 'doc-2',
      extension: 'pdf',
      bytes: Uint8List.fromList([2]),
    );

    expect(await first.exists(), isFalse);
    expect(openedFolder().listSync(), hasLength(1));
  });

  test('clearAll removes every copy, as on app start', () async {
    await files.writeForViewing(
      documentId: 'doc-1',
      extension: 'pdf',
      bytes: Uint8List.fromList([1]),
    );

    await files.clearAll();

    expect(await openedFolder().exists(), isFalse);
  });

  test('clearAll is safe when nothing was opened yet', () async {
    await files.clearAll();

    expect(await openedFolder().exists(), isFalse);
  });

  test('clearAll leaves other temporary files alone', () async {
    final other = await File('${base.path}/other.txt').writeAsString('keep');
    await files.writeForViewing(
      documentId: 'doc-1',
      extension: 'pdf',
      bytes: Uint8List.fromList([1]),
    );

    await files.clearAll();

    expect(await other.exists(), isTrue);
  });
}
