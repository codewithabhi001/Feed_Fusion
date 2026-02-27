import '../entities/feed_item_entity.dart';
import '../repository/feed_repository.dart';

/// Use case: Search across both APIs.
///
/// Cancels previous searches, resets pagination,
/// and fetches results from both APIs in parallel.
class SearchFeed {
  final FeedRepository _repository;

  SearchFeed(this._repository);

  Future<List<FeedItemEntity>> call(String query) {
    return _repository.search(query);
  }
}
