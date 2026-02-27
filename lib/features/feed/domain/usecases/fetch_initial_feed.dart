import '../entities/feed_item_entity.dart';
import '../repository/feed_repository.dart';

/// Use case: Fetch the initial feed data.
///
/// Coordinates parallel fetching from both APIs and returns
/// a merged, alternated feed list.
class FetchInitialFeed {
  final FeedRepository _repository;

  FetchInitialFeed(this._repository);

  Future<List<FeedItemEntity>> call() {
    return _repository.fetchInitial();
  }
}
