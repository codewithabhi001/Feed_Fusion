import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../../domain/usecases/fetch_initial_feed.dart';
import '../../domain/usecases/fetch_next_page.dart';
import '../../domain/usecases/search_feed.dart';
import '../../domain/repository/feed_repository.dart';

// ──────────────────────────────────────
// SEALED FEED STATES
// ──────────────────────────────────────

/// Sealed state class for type-safe state management.
/// Each state represents a distinct UI configuration.
abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedItemEntity> items;
  FeedLoaded(this.items);
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

class FeedCached extends FeedState {
  final List<FeedItemEntity> items;
  FeedCached(this.items);
}

// ──────────────────────────────────────
// FEED CONTROLLER
// ──────────────────────────────────────

/// GetX controller for the Feed feature.
///
/// Responsibilities:
/// - Handle scroll listener for pagination
/// - Handle search with debouncing
/// - Handle pull-to-refresh with cancellation
/// - Manage sealed feed states
/// - Coordinate offline/online transitions
///
/// No business logic here — all logic flows through Use Cases → Repository.
class FeedController extends GetxController {
  final FetchInitialFeed _fetchInitialFeed;
  final FetchNextPage _fetchNextPage;
  final SearchFeed _searchFeed;
  final FeedRepository _repository;
  final NetworkInfo _networkInfo;

  FeedController({
    required FetchInitialFeed fetchInitialFeed,
    required FetchNextPage fetchNextPage,
    required SearchFeed searchFeed,
    required FeedRepository repository,
    required NetworkInfo networkInfo,
  }) : _fetchInitialFeed = fetchInitialFeed,
       _fetchNextPage = fetchNextPage,
       _searchFeed = searchFeed,
       _repository = repository,
       _networkInfo = networkInfo;

  // ── Observable State ──
  final Rx<FeedState> feedState = Rx<FeedState>(FeedInitial());
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearchMode = false.obs;
  final RxBool showCachedBanner = false.obs;
  final RxString searchQuery = ''.obs;

  // ── Scroll Controller ──
  late final ScrollController scrollController;

  // ── Search Debouncer (uses ApiConstants.searchDebounceMs) ──
  final Debouncer _searchDebouncer = Debouncer(
    milliseconds: ApiConstants.searchDebounceMs,
  );

  // ── Text Controller ──
  late final TextEditingController searchTextController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    searchTextController = TextEditingController();

    // ── Real-time Connectivity Listeners ──
    // Immediately respond to network changes
    ever(_networkInfo.isConnected, _handleConnectivityChange);

    // Initial load
    loadFeed();
  }

  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      _onConnectivityRestored();
    } else {
      AppLogger.log('📡 Offline detected — showing cached state');
      showCachedBanner.value = true;

      Get.snackbar(
        'Offline',
        'You are currently offline. Showing cached data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchTextController.dispose();
    _searchDebouncer.dispose();
    _repository.cancelAllRequests();
    super.onClose();
  }

  // ──────────────────────────────────────
  // INITIAL LOAD
  // ──────────────────────────────────────

  Future<void> loadFeed() async {
    feedState.value = FeedLoading();

    // Check connectivity first
    if (!_networkInfo.isConnected.value) {
      _loadFromCache();
      return;
    }

    try {
      final items = await _fetchInitialFeed();
      feedState.value = FeedLoaded(items);
      showCachedBanner.value = false;
      AppLogger.log('✅ Feed loaded: ${items.length} items');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      _handleError(e.message ?? 'Network error');
    } catch (e) {
      _handleError(e.toString());
    }
  }

  // ──────────────────────────────────────
  // PULL-TO-REFRESH
  // ──────────────────────────────────────

  Future<void> onRefresh() async {
    AppLogger.log('🔄 Pull-to-refresh triggered');

    // Cancel ALL in-flight requests
    _repository.cancelAllRequests();
    isLoadingMore.value = false;

    // Exit search mode if active
    if (isSearchMode.value) {
      isSearchMode.value = false;
      searchQuery.value = '';
      searchTextController.clear();
    }

    if (!_networkInfo.isConnected.value) {
      _loadFromCache();
      return;
    }

    try {
      final items = await _fetchInitialFeed();
      feedState.value = FeedLoaded(items);
      showCachedBanner.value = false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      _handleError(e.message ?? 'Refresh failed');
    } catch (e) {
      _handleError(e.toString());
    }
  }

  // ──────────────────────────────────────
  // SCROLL LISTENER — PAGINATION
  // ──────────────────────────────────────

  void _onScroll() {
    // Don't paginate while in search mode, loading, or offline
    if (isSearchMode.value) return;
    if (isLoadingMore.value) return;
    if (!_networkInfo.isConnected.value) return;

    // Trigger pagination when near bottom (uses ApiConstants.paginationTriggerOffset)
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent -
            ApiConstants.paginationTriggerOffset) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value) return;
    if (!_repository.hasMoreData) return;

    isLoadingMore.value = true;

    try {
      final items = await _fetchNextPage();
      if (items.isNotEmpty) {
        feedState.value = FeedLoaded(items);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      AppLogger.logError('Pagination failed', e);
    } catch (e) {
      AppLogger.logError('Pagination error', e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ──────────────────────────────────────
  // SEARCH
  // ──────────────────────────────────────

  void onSearchChanged(String query) {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      // Exit search mode
      _searchDebouncer.cancel();
      isSearchMode.value = false;
      _repository.cancelAllRequests();
      _repository.resetPagination();
      loadFeed();
      return;
    }

    isSearchMode.value = true;
    feedState.value = FeedLoading();

    // Debounce search — wait for user to stop typing
    _searchDebouncer.run(() => _performSearch(query.trim()));
  }

  Future<void> _performSearch(String query) async {
    AppLogger.log('🔍 Searching: "$query"');

    try {
      final items = await _searchFeed(query);
      feedState.value = FeedLoaded(items);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      _handleError('Search failed');
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void clearSearch() {
    searchTextController.clear();
    onSearchChanged('');
  }

  // ──────────────────────────────────────
  // OFFLINE SUPPORT
  // ──────────────────────────────────────

  void _loadFromCache() {
    AppLogger.log('📦 Loading from cache (offline mode)');
    final cached = _repository.getCachedFeed();

    if (cached != null && cached.isNotEmpty) {
      feedState.value = FeedCached(cached);
      showCachedBanner.value = true;
    } else {
      feedState.value = FeedError(AppText.noInternetError);
    }
  }

  /// Called automatically when connectivity is restored
  void _onConnectivityRestored() {
    AppLogger.log('🌐 Connectivity restored — back to online');
    showCachedBanner.value = false;

    // Show instant success feedback
    Get.snackbar(
      'Online',
      'Connectivity restored! Refreshing feed...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade800,
      colorText: Colors.white,
      icon: const Icon(Icons.wifi_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    // If we are currently showing an error or cached data, refresh it
    if (feedState.value is FeedError ||
        feedState.value is FeedCached ||
        feedState.value is FeedInitial) {
      if (isSearchMode.value) {
        _performSearch(searchQuery.value);
      } else {
        loadFeed();
      }
      return;
    }

    // Silent refresh logic for normal loaded state
    if (isSearchMode.value) {
      _performSearch(searchQuery.value).catchError((e) {
        AppLogger.logError('Silent search refresh failed', e);
      });
      return;
    }

    // Silent refresh — don't show loading state
    _fetchInitialFeed()
        .then((items) {
          feedState.value = FeedLoaded(items);
        })
        .catchError((e) {
          AppLogger.logError('Silent refresh failed', e);
        });
  }

  // ──────────────────────────────────────
  // ERROR HANDLING
  // ──────────────────────────────────────

  void _handleError(String message) {
    // Try to show cached data on error
    final cached = _repository.getCachedFeed();
    if (cached != null && cached.isNotEmpty) {
      feedState.value = FeedCached(cached);
      showCachedBanner.value = true;
      AppLogger.log('⚠️ Error occurred but showing cached data');
    } else {
      feedState.value = FeedError(message);
    }
  }

  /// Retry after error
  void retry() {
    loadFeed();
  }

  // ── Convenience getters for UI ──

  List<FeedItemEntity> get currentItems {
    final state = feedState.value;
    if (state is FeedLoaded) return state.items;
    if (state is FeedCached) return state.items;
    return [];
  }

  bool get isLoading => feedState.value is FeedLoading;
  bool get hasError => feedState.value is FeedError;
  bool get hasData =>
      feedState.value is FeedLoaded || feedState.value is FeedCached;

  String get errorMessage {
    final state = feedState.value;
    if (state is FeedError) return state.message;
    return '';
  }
}
