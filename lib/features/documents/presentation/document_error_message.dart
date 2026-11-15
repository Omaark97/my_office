import '../../transactions/presentation/load_error_message.dart';
import '../domain/document_files.dart';

String documentErrorMessage(Object error, {required String fallback}) {
  if (error is DocumentTooLargeException) {
    return '"${error.fileName}" is larger than 10 MB and was not added.';
  }
  if (error is UnsupportedDocumentException) {
    return 'Only photos (JPEG, PNG, HEIC) and PDF files can be added.';
  }
  if (error is NotAJpegException) {
    return 'This photo could not be converted to JPEG and was not added.';
  }
  return loadErrorMessage(error, fallback: fallback);
}
