import 'dart:math';
import 'dart:typed_data';

import '../../transactions/domain/document_category.dart';

const maxDocumentBytes = 10 * 1024 * 1024;
const archiveLongestSide = 3500;
const archiveJpegQuality = 90;

const jpegMimeType = 'image/jpeg';
const pdfMimeType = 'application/pdf';

enum PickedFileKind { image, pdf, unsupported }

const _imageExtensions = {'jpg', 'jpeg', 'png', 'heic', 'heif'};

class PickedDocumentFile {
  const PickedDocumentFile({required this.path, required this.name});

  final String path;
  final String name;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }

  PickedFileKind get kind {
    if (extension == 'pdf') return PickedFileKind.pdf;
    if (_imageExtensions.contains(extension)) return PickedFileKind.image;
    return PickedFileKind.unsupported;
  }
}

class UnsupportedDocumentException implements Exception {
  const UnsupportedDocumentException(this.fileName);

  final String fileName;

  @override
  String toString() => 'UnsupportedDocumentException($fileName)';
}

class DocumentTooLargeException implements Exception {
  const DocumentTooLargeException(this.fileName, this.sizeBytes);

  final String fileName;
  final int sizeBytes;

  @override
  String toString() => 'DocumentTooLargeException($fileName, $sizeBytes)';
}

class NotAJpegException implements Exception {
  const NotAJpegException(this.fileName);

  final String fileName;

  @override
  String toString() => 'NotAJpegException($fileName)';
}

bool looksLikeJpeg(Uint8List bytes) {
  return bytes.length > 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;
}

bool looksLikePdf(Uint8List bytes) {
  return bytes.length > 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;
}

String photoDocumentName(
  DocumentCategory category,
  DateTime takenAt, {
  int? pageNumber,
}) {
  final local = takenAt.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final date =
      '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)}';
  final time = '${twoDigits(local.hour)}.${twoDigits(local.minute)}';
  final page = pageNumber == null ? '' : ' ($pageNumber)';
  return '${category.label} $date $time$page.jpg';
}

String pdfDocumentName(String pickedName) {
  final withoutFolders = pickedName.split('/').last.trim();
  if (withoutFolders.isEmpty) return 'Document.pdf';
  return withoutFolders.toLowerCase().endsWith('.pdf')
      ? withoutFolders
      : '$withoutFolders.pdf';
}

class ImageSize {
  const ImageSize(this.width, this.height);

  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is ImageSize && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => '${width}x$height';
}

ImageSize archiveSizeFor(ImageSize original) {
  final longest = max(original.width, original.height);
  if (longest <= archiveLongestSide) return original;
  final scale = archiveLongestSide / longest;
  return ImageSize(
    max(1, (original.width * scale).round()),
    max(1, (original.height * scale).round()),
  );
}

ImageSize? jpegSize(Uint8List bytes) {
  if (!looksLikeJpeg(bytes)) return null;
  var offset = 2;
  while (offset + 9 < bytes.length) {
    if (bytes[offset] != 0xFF) return null;
    final marker = bytes[offset + 1];
    if (marker == 0xFF) {
      offset++;
      continue;
    }
    final segmentLength = (bytes[offset + 2] << 8) | bytes[offset + 3];
    final isStartOfFrame =
        marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC;
    if (isStartOfFrame) {
      final height = (bytes[offset + 5] << 8) | bytes[offset + 6];
      final width = (bytes[offset + 7] << 8) | bytes[offset + 8];
      return ImageSize(width, height);
    }
    offset += 2 + segmentLength;
  }
  return null;
}
