import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/documents/data/document_sharer.dart';
import 'package:my_office/features/documents/domain/hidden_share_action.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test('hidden actions map to the iOS share sheet activity types', () {
    expect(cupertinoActivitiesFor(clientDocumentHiddenShareActions), [
      CupertinoActivityType.saveToCameraRoll,
      CupertinoActivityType.copyToPasteboard,
      CupertinoActivityType.assignToContact,
    ]);
  });
}
