/// The paths of the app's screens, in one place.
///
/// Screens navigate with `context.push(AppRoutes.transaction(id))` instead of
/// typing paths by hand.
abstract final class AppRoutes {
  static const home = '/';

  static const transactionPattern = '/transactions/:id';
  static String transaction(String id) => '/transactions/$id';

  /// The title goes in the query (`/gallery?title=...`), not the path,
  /// because titles such as "Special/General Power of Attorney" contain "/".
  static const galleryPattern = '/gallery';
  static String gallery(String title) =>
      Uri(path: galleryPattern, queryParameters: {'title': title}).toString();
}
