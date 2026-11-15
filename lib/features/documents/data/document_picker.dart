import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/document_files.dart';

abstract class DocumentPicker {
  Future<List<PickedDocumentFile>> scanDocument();

  Future<List<PickedDocumentFile>> takePhoto();

  Future<List<PickedDocumentFile>> choosePhotos();

  Future<List<PickedDocumentFile>> choosePdf();

  Future<void> clearScannedPages();
}

class PluginDocumentPicker implements DocumentPicker {
  PluginDocumentPicker({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<List<PickedDocumentFile>> scanDocument() async {
    final result = await CunningDocumentScanner.scanDocuments(
      scannerSource: ScannerSource.camera,
      output: ScanOutput.images,
      iosScannerOptions: IosScannerOptions(
        imageFormat: IosImageFormat.jpg,
        jpgCompressionQuality: 1.0,
      ),
    );
    if (result == null) return const [];
    return [
      for (final path in result.images)
        PickedDocumentFile(path: path, name: path.split('/').last),
    ];
  }

  @override
  Future<List<PickedDocumentFile>> takePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    return photo == null ? const [] : [_fromXFile(photo)];
  }

  @override
  Future<List<PickedDocumentFile>> choosePhotos() async {
    final photos = await _imagePicker.pickMultiImage(
      requestFullMetadata: false,
    );
    return [for (final photo in photos) _fromXFile(photo)];
  }

  @override
  Future<List<PickedDocumentFile>> choosePdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final path = file?.path;
    if (file == null || path == null) return const [];
    return [PickedDocumentFile(path: path, name: file.name)];
  }

  @override
  Future<void> clearScannedPages() => CunningDocumentScanner.cleanCache();

  PickedDocumentFile _fromXFile(XFile file) {
    return PickedDocumentFile(path: file.path, name: file.name);
  }
}
