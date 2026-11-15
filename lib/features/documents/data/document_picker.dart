import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/document_files.dart';

abstract class DocumentPicker {
  Future<List<PickedDocumentFile>> takePhoto();

  Future<List<PickedDocumentFile>> choosePhotos();

  Future<List<PickedDocumentFile>> choosePdf();
}

class PluginDocumentPicker implements DocumentPicker {
  PluginDocumentPicker({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

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

  PickedDocumentFile _fromXFile(XFile file) {
    return PickedDocumentFile(path: file.path, name: file.name);
  }
}
