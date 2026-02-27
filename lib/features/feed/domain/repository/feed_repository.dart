import '../entities/feed_item_entity.dart';

/// Abstract repository interface for feed operations.
///
/// Defines the contract between Domain and Data layers.
/// Implementation handles parallel fetching, merging, caching,
/// and all data source coordination.
abstract class FeedRepository {
  /// Fetches initial feed data from both sources in parallel.
  /// Returns alternated merged list of products and posts.
  Future<List<FeedItemEntity>> fetchInitial();

  /// Fetches next page from the source with fewer items.
  /// Implements smart pagination logic.
  Future<List<FeedItemEntity>> fetchNext();

  /// Searches both APIs with the given query.
  /// Cancels any previous search requests.
  /// Returns alternated merged results.
  Future<List<FeedItemEntity>> search(String query);

  /// Refreshes feed data — cancels in-flight requests and fetches fresh.
  Future<List<FeedItemEntity>> refresh();

  /// Retrieves cached feed data for offline mode
  List<FeedItemEntity>? getCachedFeed();

  /// Resets all pagination state
  void resetPagination();

  /// Cancels all active requests
  void cancelAllRequests();

  /// Whether more data is available to fetch
  bool get hasMoreData;
}
