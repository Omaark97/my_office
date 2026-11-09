import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void useIPhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}
