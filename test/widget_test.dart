import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_office/app/app.dart';

void main() {
  testWidgets('App starts and shows the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // The app has the right name (used by iOS in the app switcher).
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'My Office');

    // The home screen is visible, with its app bar title.
    expect(find.text('Home'), findsOneWidget);

    // The test data is shown in the list.
    expect(find.text('Test User 1'), findsOneWidget);
  });
}
