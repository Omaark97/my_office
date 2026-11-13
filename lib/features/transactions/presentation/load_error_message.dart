import '../domain/archive_access_denied_exception.dart';

const archiveAccessDeniedMessage =
    "This account doesn't have access to the archive.";

String loadErrorMessage(Object error, {required String fallback}) {
  return error is ArchiveAccessDeniedException
      ? archiveAccessDeniedMessage
      : fallback;
}
