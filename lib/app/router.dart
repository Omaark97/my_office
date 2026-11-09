import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/screens/loading_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/transactions/presentation/screens/document_gallery_screen.dart';
import '../features/transactions/presentation/screens/home_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<AsyncValue<AppUser?>>(const AsyncLoading());
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (previous, next) => authState.value = next,
    fireImmediately: true,
  );

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authState,
    redirect: (context, state) =>
        authRedirect(authState.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.loading,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
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
  ref.onDispose(() {
    router.dispose();
    authState.dispose();
  });
  return router;
});

String? authRedirect(AsyncValue<AppUser?> authState, String location) {
  final stillChecking = authState.isLoading && !authState.hasValue;
  if (stillChecking) {
    return location == AppRoutes.loading ? null : AppRoutes.loading;
  }

  final signedIn = authState.value != null;
  if (!signedIn) {
    return location == AppRoutes.login ? null : AppRoutes.login;
  }

  final onAuthScreen =
      location == AppRoutes.login || location == AppRoutes.loading;
  return onAuthScreen ? AppRoutes.home : null;
}
