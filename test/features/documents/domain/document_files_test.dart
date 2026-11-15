import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/documents/domain/document_files.dart';
import 'package:my_office/features/documents/domain/document_storage.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';

Uint8List _jpegHeader({
  required int width,
  required int height,
  int frameMarker = 0xC0,
}) {
  return Uint8List.fromList([
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
    0x49,
    0x46,
    0x00,
    0x01,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x01,
    0x00,
    0x00,
    0xFF,
    frameMarker,
    0x00,
    0x11,
    0x08,
    height >> 8,
    height & 0xFF,
    width >> 8,
    width & 0xFF,
    0x03,
    0x01,
    0x22,
    0x00,
    0x02,
    0x11,
    0x01,
    0x03,
    0x11,
    0x01,
    0xFF,
    0xD9,
  ]);
}

void main() {
  group('PickedDocumentFile.kind', () {
    PickedFileKind kindOf(String name) =>
        PickedDocumentFile(path: '/tmp/$name', name: name).kind;

    test('iPhone HEIC and HEIF photos count as images', () {
      expect(kindOf('IMG_0001.HEIC'), PickedFileKind.image);
      expect(kindOf('IMG_0002.heif'), PickedFileKind.image);
    });

    test('JPEG and PNG count as images', () {
      expect(kindOf('scan.jpg'), PickedFileKind.image);
      expect(kindOf('scan.JPEG'), PickedFileKind.image);
      expect(kindOf('screenshot.png'), PickedFileKind.image);
    });

    test('PDF is a PDF', () {
      expect(kindOf('Sale_Deed.PDF'), PickedFileKind.pdf);
    });

    test('anything else is unsupported', () {
      expect(kindOf('notes.docx'), PickedFileKind.unsupported);
      expect(kindOf('animation.gif'), PickedFileKind.unsupported);
      expect(kindOf('no_extension'), PickedFileKind.unsupported);
    });
  });

  group('file signatures', () {
    test('recognizes a JPEG by its first bytes', () {
      expect(looksLikeJpeg(_jpegHeader(width: 10, height: 10)), isTrue);
    });

    test('a HEIC file is not a JPEG', () {
      final heicStart = Uint8List.fromList([
        0x00,
        0x00,
        0x00,
        0x18,
        0x66,
        0x74,
        0x79,
        0x70,
        0x68,
        0x65,
        0x69,
        0x63,
      ]);
      expect(looksLikeJpeg(heicStart), isFalse);
    });

    test('recognizes a PDF by its first bytes', () {
      expect(looksLikePdf(Uint8List.fromList('%PDF-1.7'.codeUnits)), isTrue);
      expect(looksLikePdf(_jpegHeader(width: 1, height: 1)), isFalse);
    });
  });

  group('jpegSize', () {
    test('reads width and height from the JPEG header', () {
      expect(
        jpegSize(_jpegHeader(width: 4032, height: 3024)),
        const ImageSize(4032, 3024),
      );
    });

    test('also reads progressive JPEGs', () {
      expect(
        jpegSize(_jpegHeader(width: 3024, height: 4032, frameMarker: 0xC2)),
        const ImageSize(3024, 4032),
      );
    });

    test('returns null for data that is not a JPEG', () {
      expect(jpegSize(Uint8List.fromList('%PDF-1.7'.codeUnits)), isNull);
    });
  });

  group('archiveSizeFor', () {
    test('scales a 12 MP landscape photo to 3500 px on the long side', () {
      expect(
        archiveSizeFor(const ImageSize(4032, 3024)),
        const ImageSize(3500, 2625),
      );
    });

    test('scales a portrait photo by its height', () {
      expect(
        archiveSizeFor(const ImageSize(3024, 4032)),
        const ImageSize(2625, 3500),
      );
    });

    test('an A4 page at 300 DPI shrinks only slightly', () {
      expect(
        archiveSizeFor(const ImageSize(2480, 3508)),
        const ImageSize(2474, 3500),
      );
    });

    test('never enlarges a smaller image', () {
      expect(
        archiveSizeFor(const ImageSize(1200, 1600)),
        const ImageSize(1200, 1600),
      );
    });
  });

  group('names', () {
    final takenAt = DateTime(2026, 11, 15, 10, 30);

    test('photos are named after the category, date and time', () {
      expect(
        photoDocumentName(DocumentCategory.saleDeed, takenAt),
        'Vehicle Sale Deeds 2026-11-15 10.30.jpg',
      );
    });

    test('multi-photo picks are numbered to keep the page order', () {
      expect(
        photoDocumentName(DocumentCategory.saleDeed, takenAt, pageNumber: 1),
        'Vehicle Sale Deeds 2026-11-15 10.30 (1).jpg',
      );
      expect(
        photoDocumentName(DocumentCategory.saleDeed, takenAt, pageNumber: 12),
        'Vehicle Sale Deeds 2026-11-15 10.30 (12).jpg',
      );
    });

    test('PDFs keep their own name', () {
      expect(pdfDocumentName('Notary_POA.pdf'), 'Notary_POA.pdf');
      expect(pdfDocumentName('/private/var/tmp/Deed.PDF'), 'Deed.PDF');
      expect(pdfDocumentName('Scan'), 'Scan.pdf');
      expect(pdfDocumentName('  '), 'Document.pdf');
    });
  });

  test('the storage path sits in the transaction folder', () {
    expect(
      documentStoragePath(
        transactionId: 'tx-1',
        documentId: 'doc-1',
        extension: 'jpg',
      ),
      'transactions/tx-1/documents/doc-1.jpg',
    );
  });
}
