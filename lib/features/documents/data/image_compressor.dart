import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../domain/document_files.dart';

abstract class ImageCompressor {
  Future<Uint8List> toArchiveJpeg(String imagePath);
}

class NativeImageCompressor implements ImageCompressor {
  static const _keepFullSize = 20000;

  @override
  Future<Uint8List> toArchiveJpeg(String imagePath) async {
    final uprightFullSize = await FlutterImageCompress.compressWithFile(
      imagePath,
      minWidth: _keepFullSize,
      minHeight: _keepFullSize,
      quality: 100,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    if (uprightFullSize == null) {
      throw StateError('Could not read the image at $imagePath');
    }
    final size = jpegSize(uprightFullSize);
    if (size == null) return uprightFullSize;

    final target = archiveSizeFor(size);
    return FlutterImageCompress.compressWithList(
      uprightFullSize,
      minWidth: target.width,
      minHeight: target.height,
      quality: archiveJpegQuality,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: false,
      keepExif: false,
    );
  }
}
