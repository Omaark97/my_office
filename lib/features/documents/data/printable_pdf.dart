import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _pageMargin = 18.0;

Future<Uint8List> imageAsPrintablePdf(
  Uint8List imageBytes, {
  required String title,
}) {
  final image = pw.MemoryImage(imageBytes);
  final isLandscape = (image.width ?? 0) > (image.height ?? 0);
  final document = pw.Document(title: title);
  document.addPage(
    pw.Page(
      pageFormat: isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_pageMargin),
      build: (context) =>
          pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
    ),
  );
  return document.save();
}
