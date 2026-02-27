import 'package:dio/dio.dart';
import '../../../../core/cache/local_cache.dart';
import '../../../../core/cache/lru_cache.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repository/feed_repository.dart';
import '../datasource/product_remote_ds.dart';
import '../datasource/post_remote_ds.dart';
import '../models/product_model.dart';
import '../models/post_model.dart';

/// Production-grade Feed Repository Implementation.
///
/// Responsibilities:
/// 1. Parallel fetching from Products and Posts APIs
/// 2. Alternating merge logic (Product → Post → Product → Post ...)
/// 3. Smart pagination — fetches from source with fewer items
/// 4. Request deduplication via DioClient
/// 5. CancelToken management for cancellation
/// 6. Two-layer caching: LRU (in-memory) + LocalCache (persistent)
/// 7. Performance logging for all operations
/// 8. Graceful degradation — shows partial data if one API fails
class FeedRepositoryImpl implements FeedRepository {
  final ProductRemoteDataSource _productDS;
  final PostRemoteDataSource _postDS;
  final DioClient _dioClient;
  final LocalCache _localCache;

  // In-memory LRU cache for fast access
  final LruCache<String, List<FeedItemEntity>> _lruCache = LruCache(
    maxSize: 20,
  );

  // ──────────────────────────────────────
  // PAGINATION STATE
  // ──────────────────────────────────────
  int _productPage = 1;
  int _postPage = 1;
  int _productCount = 0;
  int _postCount = 0;
  int _totalProducts = 0;
  int _totalPosts = 0;

  // ──────────────────────────────────────
  // CONCURRENCY CONTROL
  // ──────────────────────────────────────

  /// Mutex flag — prevents duplicate pagination calls during aggressive scrolling
  bool _isLoadingMore = false;

  // All fetched items stored for re-merging
  final List<ProductEntity> _allProducts = [];
  final List<PostEntity> _allPosts = [];

  FeedRepositoryImpl({
    required ProductRemoteDataSource productDS,
    required PostRemoteDataSource postDS,
    required DioClient dioClient,
    required LocalCache localCache,
  }) : _productDS = productDS,
       _postDS = postDS,
       _dioClient = dioClient,
       _localCache = localCache;

  @override
  bool get hasMoreData =>
      _productCount < _totalProducts || _postCount < _totalPosts;

  // ──────────────────────────────────────
  // FETCH INITIAL
  // ──────────────────────────────────────

  @override
  Future<List<FeedItemEntity>> fetchInitial() async {
    // Check LRU cache first
    final cached = _lruCache.get('initial_feed');
    if (cached != null) {
      AppLogger.log('⚡ LRU cache hit for initial feed');
      return cached;
    }

    // Cancel any leftover requests
    _dioClient.cancelAll();
    resetPagination();

    final cancelToken = _dioClient.getCancelToken('initial_feed');

    // ──────────────────────────────────────
    // PARALLEL FETCH: Products + Posts simultaneously
    // ──────────────────────────────────────
    final stopwatch = Stopwatch()..start();

    // Fetch both sources in parallel
    // If one fails, we still show data from the other (graceful degradation)
    final results = await Future.wait([
      _fetchProductsSafe(page: 1, cancelToken: cancelToken),
      _fetchPostsSafe(page: 1, cancelToken: cancelToken),
    ]);

    final productsResult = results[0] as _ProductsResult;
    final postsResult = results[1] as _PostsResult;

    // Update state
    _allProducts.addAll(productsResult.products);
    _allPosts.addAll(postsResult.posts);
    _productCount = _allProducts.length;
    _postCount = _allPosts.length;
    _totalProducts = productsResult.total;
    _totalPosts = postsResult.total;
    _productPage = 2; // Next page to fetch
    _postPage = 2;

    // Merge alternately
    final merged = _mergeAlternately(_allProducts, _allPosts);

    stopwatch.stop();
    AppLogger.logMergeTime(
      _allProducts.length,
      _allPosts.length,
      stopwatch.elapsedMilliseconds,
    );

    // Cache results
    _lruCache.put('initial_feed', merged, ttl: const Duration(minutes: 5));
    _saveToPersistentCache(merged);

    AppLogger.logPagination(
      productPage: _productPage,
      postPage: _postPage,
      productCount: _productCount,
      postCount: _postCount,
    );

    return merged;
  }

  // ──────────────────────────────────────
  // FETCH NEXT PAGE (SMART PAGINATION)
  // ──────────────────────────────────────

  @override
  Future<List<FeedItemEntity>> fetchNext() async {
    // ── MUTEX: Prevent duplicate pagination calls ──
    // During aggressive scrolling, multiple scroll events can fire
    // before the first pagination request completes. This guard
    // ensures only one pagination request is active at a time.
    if (_isLoadingMore) {
      AppLogger.log('🔒 Pagination locked — request already in progress');
      return [];
    }

    if (!hasMoreData) {
      AppLogger.log('📄 No more data available');
      return [];
    }

    _isLoadingMore = true;

    try {
      final cancelToken = _dioClient.getCancelToken('pagination');

      // ── SMART PAGINATION LOGIC ──
      // Fetch from the source with fewer items to maintain balance.
      // This ensures the alternating merge pattern stays consistent.
      if (_productCount <= _postCount && _productCount < _totalProducts) {
        // Fetch more products
        AppLogger.log(
          '📄 Smart pagination → fetching Products page $_productPage',
        );
        final result = await _fetchProductsSafe(
          page: _productPage,
          cancelToken: cancelToken,
        );

        _allProducts.addAll(result.products);
        _productCount = _allProducts.length;
        _productPage++;
      } else if (_postCount < _totalPosts) {
        // Fetch more posts
        AppLogger.log('📄 Smart pagination → fetching Posts page $_postPage');
        final result = await _fetchPostsSafe(
          page: _postPage,
          cancelToken: cancelToken,
        );

        _allPosts.addAll(result.posts);
        _postCount = _allPosts.length;
        _postPage++;
      }

      // Re-merge all items
      final merged = _mergeAlternately(_allProducts, _allPosts);

      // Update cache
      _lruCache.put('initial_feed', merged, ttl: const Duration(minutes: 5));
      _saveToPersistentCache(merged);

      AppLogger.logPagination(
        productPage: _productPage,
        postPage: _postPage,
        productCount: _productCount,
        postCount: _postCount,
      );

      return merged;
    } finally {
      // ── Release mutex in finally block to prevent deadlocks ──
      _isLoadingMore = false;
    }
  }

  // ──────────────────────────────────────
  // SEARCH
  // ──────────────────────────────────────

  @override
  Future<List<FeedItemEntity>> search(String query) async {
    if (query.trim().isEmpty) {
      return fetchInitial();
    }

    // Check LRU cache for this query
    final cacheKey = 'search_$query';
    final cached = _lruCache.get(cacheKey);
    if (cached != null) {
      AppLogger.log('⚡ LRU cache hit for search: "$query"');
      return cached;
    }

    // ── Cancel ALL active requests before starting new search ──
    // This ensures previous pagination/search requests don't
    // interfere with the new search results.
    _dioClient.cancelAll();
    _isLoadingMore = false;

    final cancelToken = _dioClient.getCancelToken('search');

    // Parallel search across both APIs
    final results = await Future.wait([
      _searchProductsSafe(query: query, cancelToken: cancelToken),
      _searchPostsSafe(query: query, cancelToken: cancelToken),
    ]);

    final products = results[0] as List<ProductModel>?;
    final posts = results[1] as List<PostModel>?;

    if (products == null && posts == null) {
      throw Exception('Failed to search data. Please check your connection.');
    }

    final merged = _mergeAlternately(products ?? [], posts ?? []);

    // Cache search results (shorter TTL)
    _lruCache.put(cacheKey, merged, ttl: const Duration(minutes: 2));

    return merged;
  }

  // ──────────────────────────────────────
  // REFRESH
  // ──────────────────────────────────────

  @override
  Future<List<FeedItemEntity>> refresh() async {
    // Cancel ALL in-flight requests (pagination, search, etc.)
    _dioClient.cancelAll();
    _isLoadingMore = false;

    // Clear caches
    _lruCache.clear();

    // Reset and fetch fresh
    return fetchInitial();
  }

  // ──────────────────────────────────────
  // CACHED FEED (OFFLINE)
  // ──────────────────────────────────────

  @override
  List<FeedItemEntity>? getCachedFeed() {
    // Try LRU first
    final lruCached = _lruCache.get('initial_feed');
    if (lruCached != null) return lruCached;

    // Fall back to persistent cache
    final cachedJson = _localCache.getCachedFeedData();
    if (cachedJson == null) return null;

    try {
      final items = cachedJson.map((json) {
        final type = json['type'] as String?;
        if (type == 'product') {
          return ProductFeedItem(product: ProductModel.fromCacheJson(json));
        } else {
          return PostFeedItem(post: PostModel.fromCacheJson(json));
        }
      }).toList();

      // Populate LRU cache from persistent cache
      _lruCache.put('initial_feed', items, ttl: const Duration(minutes: 5));

      return items;
    } catch (e) {
      AppLogger.logError('Failed to deserialize cached feed', e);
      return null;
    }
  }

  @override
  void resetPagination() {
    _productPage = 1;
    _postPage = 1;
    _productCount = 0;
    _postCount = 0;
    _totalProducts = 0;
    _totalPosts = 0;
    _isLoadingMore = false;
    _allProducts.clear();
    _allPosts.clear();
  }

  @override
  void cancelAllRequests() {
    _dioClient.cancelAll();
    _isLoadingMore = false;
  }

  // ══════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════

  /// Merges products and posts in alternating order.
  ///
  /// Pattern: P1, S1, P2, S2, P3, S3, ...
  /// If one list is longer, remaining items are appended at the end.
  List<FeedItemEntity> _mergeAlternately(
    List<ProductEntity> products,
    List<PostEntity> posts,
  ) {
    final stopwatch = Stopwatch()..start();
    final merged = <FeedItemEntity>[];
    final maxLen = products.length > posts.length
        ? products.length
        : posts.length;

    for (int i = 0; i < maxLen; i++) {
      if (i < products.length) {
        merged.add(ProductFeedItem(product: products[i]));
      }
      if (i < posts.length) {
        merged.add(PostFeedItem(post: posts[i]));
      }
    }

    stopwatch.stop();
    AppLogger.logMergeTime(
      products.length,
      posts.length,
      stopwatch.elapsedMilliseconds,
    );

    return merged;
  }

  /// Saves merged feed to persistent cache for offline use
  void _saveToPersistentCache(List<FeedItemEntity> items) {
    try {
      final jsonList = items.map((item) {
        switch (item) {
          case ProductFeedItem(:final product):
            if (product is ProductModel) return product.toJson();
            return {
              'type': 'product',
              'id': product.id,
              'title': product.title,
            };
          case PostFeedItem(:final post):
            if (post is PostModel) return post.toJson();
            return {'type': 'post', 'id': post.id, 'title': post.title};
        }
      }).toList();

      _localCache.saveFeedData(jsonList);
    } catch (e) {
      AppLogger.logError('Failed to save to persistent cache', e);
    }
  }

  // ── Safe API wrappers with error handling ──
  // These catch errors from individual sources so the feed
  // can still show data from the other source (graceful degradation).

  Future<_ProductsResult> _fetchProductsSafe({
    required int page,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _productDS.fetchProducts(
        page: page,
        cancelToken: cancelToken,
      );
      return _ProductsResult(
        products: response.products,
        total: response.total,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      AppLogger.logError('Products API failed (page: $page)', e);
      return _ProductsResult(products: [], total: _totalProducts);
    } catch (e) {
      AppLogger.logError('Unexpected error fetching products', e);
      return _ProductsResult(products: [], total: _totalProducts);
    }
  }

  Future<_PostsResult> _fetchPostsSafe({
    required int page,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _postDS.fetchPosts(
        page: page,
        cancelToken: cancelToken,
      );
      return _PostsResult(posts: response.posts, total: response.total);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      AppLogger.logError('Posts API failed (page: $page)', e);
      return _PostsResult(posts: [], total: _totalPosts);
    } catch (e) {
      AppLogger.logError('Unexpected error fetching posts', e);
      return _PostsResult(posts: [], total: _totalPosts);
    }
  }

  Future<List<ProductModel>?> _searchProductsSafe({
    required String query,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _productDS.searchProducts(
        query: query,
        cancelToken: cancelToken,
      );
      return response.products;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      AppLogger.logError('Product search failed: "$query"', e);
      return null;
    }
  }

  Future<List<PostModel>?> _searchPostsSafe({
    required String query,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _postDS.searchPosts(
        query: query,
        cancelToken: cancelToken,
      );
      return response.posts;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      AppLogger.logError('Post search failed: "$query"', e);
      return null;
    }
  }
}

/// Internal result wrapper for products
class _ProductsResult {
  final List<ProductModel> products;
  final int total;

  _ProductsResult({required this.products, required this.total});
}

/// Internal result wrapper for posts
class _PostsResult {
  final List<PostModel> posts;
  final int total;

  _PostsResult({required this.posts, required this.total});
}
