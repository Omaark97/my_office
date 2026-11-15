import 'package:open_filex/open_filex.dart';

abstract class DocumentOpener {
  Future<void> openPdf(String filePath);
}

class SystemDocumentOpener implements DocumentOpener {
  @override
  Future<void> openPdf(String filePath) async {
    final result = await OpenFilex.open(
      filePath,
      type: 'application/pdf',
      uti: 'com.adobe.pdf',
    );
    if (result.type != ResultType.done) {
      throw StateError('Could not open the PDF: ${result.message}');
    }
  }
}
