import 'package:share_plus/share_plus.dart';

import '../domain/hidden_share_action.dart';

abstract class DocumentSharer {
  Future<void> shareFile(
    String filePath, {
    required String mimeType,
    required List<HiddenShareAction> hiddenActions,
  });
}

class SystemDocumentSharer implements DocumentSharer {
  @override
  Future<void> shareFile(
    String filePath, {
    required String mimeType,
    required List<HiddenShareAction> hiddenActions,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: mimeType)],
        excludedCupertinoActivities: cupertinoActivitiesFor(hiddenActions),
      ),
    );
  }
}

List<CupertinoActivityType> cupertinoActivitiesFor(
  List<HiddenShareAction> hiddenActions,
) {
  return [
    for (final action in hiddenActions)
      switch (action) {
        HiddenShareAction.saveToPhotos =>
          CupertinoActivityType.saveToCameraRoll,
        HiddenShareAction.copy => CupertinoActivityType.copyToPasteboard,
        HiddenShareAction.assignToContact =>
          CupertinoActivityType.assignToContact,
      },
  ];
}
