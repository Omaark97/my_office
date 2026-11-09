abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const loading = '/loading';

  static const transactionPattern = '/transactions/:id';
  static String transaction(String id) => '/transactions/$id';

  static const galleryPattern = '/gallery';
  static String gallery(String title) =>
      Uri(path: galleryPattern, queryParameters: {'title': title}).toString();
}
