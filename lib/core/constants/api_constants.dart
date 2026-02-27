/// Centralized API constants.
///
/// All API URLs and endpoint configurations are managed from here.
/// This ensures consistency and easy maintenance across the app.
class ApiConstants {
  // ── Base URL ──
  static const String baseUrl = 'https://dummyjson.com';

  // ── Products Endpoints ──
  static const String products = '/products';
  static const String productsSearch = '/products/search';

  // ── Posts Endpoints ──
  static const String posts = '/posts';
  static const String postsSearch = '/posts/search';

  // ── Pagination Defaults ──
  static const int defaultPageSize = 10;
  static const int searchResultLimit = 10;

  // ── Timeouts (in seconds) ──
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // ── Cache Configuration ──
  static const int cacheExpiryMinutes = 5;
  static const int searchCacheExpiryMinutes = 2;

  // ── Debounce ──
  static const int searchDebounceMs = 500;

  // ── Scroll Pagination Trigger ──
  static const double paginationTriggerOffset = 200.0;

  // ── Products API Field Selection ──
  /// Selected fields to minimize payload size
  static const String productFields =
      'id,title,description,price,discountPercentage,rating,stock,brand,category,thumbnail,images,tags';

  // ── Full URLs (for reference/logging) ──
  static String get productsFullUrl => '$baseUrl$products';
  static String get postsFullUrl => '$baseUrl$posts';
  static String get productsSearchFullUrl => '$baseUrl$productsSearch';
  static String get postsSearchFullUrl => '$baseUrl$postsSearch';
}
