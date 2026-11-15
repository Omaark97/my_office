import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:my_office/features/documents/data/printable_pdf.dart';
import 'package:my_office/features/documents/domain/document_files.dart';

Uint8List _jpeg({required int width, required int height}) {
  return img.encodeJpg(img.Image(width: width, height: height), quality: 90);
}

String _asText(Uint8List pdf) => latin1.decode(pdf, allowInvalid: true);

bool _contains(Uint8List haystack, Uint8List needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

void main() {
  test('wraps an image in a valid one-page PDF', () async {
    final pdf = await imageAsPrintablePdf(
      _jpeg(width: 30, height: 40),
      title: 'Scan',
    );

    expect(looksLikePdf(pdf), isTrue);
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(_asText(pdf)), hasLength(1));
  });

  test(
    'embeds the original JPEG unchanged, so print quality is kept',
    () async {
      final jpeg = _jpeg(width: 30, height: 40);

      final pdf = await imageAsPrintablePdf(jpeg, title: 'Scan');

      expect(_asText(pdf), contains('/DCTDecode'));
      expect(_contains(pdf, jpeg), isTrue);
    },
  );

  test('a portrait photo gets a portrait A4 page', () async {
    final pdf = await imageAsPrintablePdf(
      _jpeg(width: 30, height: 40),
      title: 'Scan',
    );

    expect(
      _asText(pdf),
      matches(RegExp(r'/MediaBox\s*\[\s*0 0 595\.\d+ 841\.\d+')),
    );
  });

  test('a landscape photo gets a landscape A4 page', () async {
    final pdf = await imageAsPrintablePdf(
      _jpeg(width: 40, height: 30),
      title: 'Scan',
    );

    expect(
      _asText(pdf),
      matches(RegExp(r'/MediaBox\s*\[\s*0 0 841\.\d+ 595\.\d+')),
    );
  });
}
