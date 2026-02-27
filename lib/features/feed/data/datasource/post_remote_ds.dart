import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/post_model.dart';

/// Remote data source for Posts API.
///
/// Handles pagination, search, and CancelToken management
/// for the dummyjson.com/posts endpoint.
class PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSource(this._dioClient);

  /// Fetches a page of posts.
  ///
  /// [page] — 1-indexed page number
  /// [limit] — items per page (default: 10)
  /// [cancelToken] — for request cancellation
  Future<PostsResponse> fetchPosts({
    required int page,
    int limit = ApiConstants.defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final skip = (page - 1) * limit;

    final response = await _dioClient.get(
      ApiConstants.posts,
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
      deduplicationKey: 'posts_page_$page',
    );

    final data = response.data as Map<String, dynamic>;
    final posts = (data['posts'] as List<dynamic>)
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final total = data['total'] as int? ?? 0;

    AppLogger.log(
      '📝 Fetched ${posts.length} posts (page: $page, total: $total)',
    );

    return PostsResponse(posts: posts, total: total, skip: skip, limit: limit);
  }

  /// Searches posts by query string.
  Future<PostsResponse> searchPosts({
    required String query,
    int limit = ApiConstants.searchResultLimit,
    CancelToken? cancelToken,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.postsSearch,
      queryParameters: {'q': query, 'limit': limit},
      cancelToken: cancelToken,
      deduplicationKey: 'posts_search_$query',
    );

    final data = response.data as Map<String, dynamic>;
    final posts = (data['posts'] as List<dynamic>)
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final total = data['total'] as int? ?? 0;

    return PostsResponse(posts: posts, total: total, skip: 0, limit: limit);
  }
}

/// Response wrapper for posts API
class PostsResponse {
  final List<PostModel> posts;
  final int total;
  final int skip;
  final int limit;

  const PostsResponse({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + posts.length < total;
}
