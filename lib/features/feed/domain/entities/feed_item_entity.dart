import 'product_entity.dart';
import 'post_entity.dart';

/// Sealed type for unified feed items.
///
/// A feed item is either a Product or a Post.
/// This enables type-safe rendering in the UI layer.
///
/// Usage:
/// ```dart
/// switch (feedItem) {
///   case ProductFeedItem(:final product):
///     // render product card
///   case PostFeedItem(:final post):
///     // render post card
/// }
/// ```
sealed class FeedItemEntity {
  final String feedId; // Unique ID across both types
  final DateTime addedAt;

  const FeedItemEntity({required this.feedId, required this.addedAt});
}

/// Feed item wrapping a Product
class ProductFeedItem extends FeedItemEntity {
  final ProductEntity product;

  ProductFeedItem({required this.product})
    : super(feedId: 'product_${product.id}', addedAt: DateTime.now());
}

/// Feed item wrapping a Post
class PostFeedItem extends FeedItemEntity {
  final PostEntity post;

  PostFeedItem({required this.post})
    : super(feedId: 'post_${post.id}', addedAt: DateTime.now());
}
