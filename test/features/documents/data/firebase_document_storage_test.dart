import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/documents/data/firebase_document_storage.dart';
import 'package:my_office/features/transactions/domain/archive_access_denied_exception.dart';

void main() {
  FirebaseException storageError(String code) =>
      FirebaseException(plugin: 'firebase_storage', code: code);

  test('unauthorized and unauthenticated mean no access to the archive', () {
    expect(
      storageErrorFrom(storageError('unauthorized')),
      isA<ArchiveAccessDeniedException>(),
    );
    expect(
      storageErrorFrom(storageError('unauthenticated')),
      isA<ArchiveAccessDeniedException>(),
    );
  });

  test('a missing file becomes a StateError', () {
    expect(
      storageErrorFrom(storageError('object-not-found')),
      isA<StateError>(),
    );
  });

  test('other errors are passed on unchanged', () {
    final original = storageError('retry-limit-exceeded');

    expect(storageErrorFrom(original), same(original));
  });
}
