/// Centralized App Strings / Text Constants.
///
/// All user-facing text is managed from this single file.
/// Makes localization and text changes easy and consistent.
class AppText {
  // ── App ──
  static const String appName = 'Feed Fusion';

  // ── AppBar ──
  static const String searchHint = 'Search products & posts...';
  static const String appLogoText = 'FF';

  // ── Feed States ──
  static const String loadingMore = 'Loading more...';
  static const String noResultsTitle = 'No results found';
  static const String noResultsSubtitle =
      'Try different keywords or clear the search';
  static const String errorTitle = 'Oops! Something went wrong';
  static const String retryButton = 'Try Again';

  // ── Offline / Cache ──
  static const String cachedDataMessage =
      'Showing cached data • Connect to internet for latest updates';
  static const String noInternetError =
      'No internet connection and no cached data available';

  // ── Card Labels ──
  static const String likeAction = 'Like';
  static const String commentAction = 'Comment';
  static const String shareAction = 'Share';
  static const String saveAction = 'Save';
  static const String repostAction = 'Repost';
  static const String sendAction = 'Send';
  static const String sharedAPost = 'Shared a post';
  static const String productLabel = 'Product';
  static const String unknownBrand = 'Unknown';
  static const String inStock = 'in stock';
  static const String reactions = 'reactions';
  static const String views = 'views';

  // ── Logging ──
  static const String logTag = 'FeedFusion';
}
