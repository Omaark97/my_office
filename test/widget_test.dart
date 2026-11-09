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

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'My Office');

    expect(find.text('Home'), findsOneWidget);

    expect(find.text('Test User 1'), findsOneWidget);
  });
}
