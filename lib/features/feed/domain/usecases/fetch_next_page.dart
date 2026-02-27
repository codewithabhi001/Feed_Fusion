import '../entities/feed_item_entity.dart';
import '../repository/feed_repository.dart';

/// Use case: Fetch the next page based on smart pagination.
///
/// Determines which source needs more data and fetches
/// only from that source to maintain balance.
class FetchNextPage {
  final FeedRepository _repository;

  FetchNextPage(this._repository);

  Future<List<FeedItemEntity>> call() {
    return _repository.fetchNext();
  }
}
