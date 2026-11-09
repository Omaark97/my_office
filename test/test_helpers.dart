import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes the test screen the size of an iPhone (390 x 844 points) instead of
/// the default 800 x 600, so tests see the same layout as the real app.
void useIPhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}
