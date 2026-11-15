import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class TemporaryDocumentFiles {
  TemporaryDocumentFiles({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getTemporaryDirectory;

  static const folderName = 'opened_documents';

  final Future<Directory> Function() _baseDirectory;

  Future<Directory> _folder() async {
    final base = await _baseDirectory();
    return Directory('${base.path}/$folderName');
  }

  Future<File> writeForViewing({
    required String documentId,
    required String extension,
    required Uint8List bytes,
  }) async {
    await clearAll();
    final folder = await _folder();
    await folder.create(recursive: true);
    final file = File('${folder.path}/$documentId.$extension');
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> clearAll() async {
    final folder = await _folder();
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }
}
