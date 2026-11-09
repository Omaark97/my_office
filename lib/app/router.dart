import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/transactions/presentation/screens/document_gallery_screen.dart';
import '../features/transactions/presentation/screens/home_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(title: 'Home'),
      ),
      GoRoute(
        path: AppRoutes.transactionPattern,
        builder: (context, state) =>
            TransactionDetailScreen(transactionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.galleryPattern,
        builder: (context, state) => DocumentGalleryScreen(
          title: state.uri.queryParameters['title'] ?? '',
          imageUrls: const [],
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
