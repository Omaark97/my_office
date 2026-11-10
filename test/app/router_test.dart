import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/app/app.dart';
import 'package:my_office/app/router.dart';
import 'package:my_office/app/routes.dart';
import 'package:my_office/features/auth/presentation/auth_providers.dart';
import 'package:my_office/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:my_office/features/transactions/presentation/transaction_providers.dart';

import '../features/auth/fake_auth_repository.dart';
import '../test_helpers.dart';

Future<ProviderContainer> _pumpApp(WidgetTester tester) async {
  useIPhoneScreen(tester);
  final container = ProviderContainer.test(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        InMemoryTransactionRepository(),
      ),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(signedInUser: testUser),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  test('gallery paths keep a "/" in the title intact', () {
    final path = AppRoutes.gallery('Special/General Power of Attorney');

    expect(Uri.parse(path).path, '/gallery');
    expect(
      Uri.parse(path).queryParameters['title'],
      'Special/General Power of Attorney',
    );
  });

  testWidgets('tapping a transaction opens its details, back returns home', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Test User 2'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text("Driver's License Renewal"), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);
  });

  testWidgets('tapping a Quick Access card opens the gallery', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Identification Documents'));
    await tester.pumpAndSettle();

    expect(find.text('Identification Documents'), findsOneWidget);
    expect(find.text('Quick Access'), findsNothing);
  });

  testWidgets('opens a gallery whose title contains "/"', (tester) async {
    final container = await _pumpApp(tester);

    container
        .read(routerProvider)
        .push(AppRoutes.gallery('Special/General Power of Attorney'));
    await tester.pumpAndSettle();

    expect(find.text('Special/General Power of Attorney'), findsOneWidget);
    expect(find.text('Quick Access'), findsNothing);
  });

  testWidgets('a transaction path opens that transaction', (tester) async {
    final container = await _pumpApp(tester);

    container.read(routerProvider).push(AppRoutes.transaction('test-4'));
    await tester.pumpAndSettle();

    expect(find.text('Private Car Ownership Transfer'), findsOneWidget);
    expect(find.text('Test User 4'), findsOneWidget);
  });
}
