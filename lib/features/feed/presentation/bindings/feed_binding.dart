import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/cache/local_cache.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasource/product_remote_ds.dart';
import '../../data/datasource/post_remote_ds.dart';
import '../../data/repository_impl/feed_repository_impl.dart';
import '../../domain/usecases/fetch_initial_feed.dart';
import '../../domain/usecases/fetch_next_page.dart';
import '../../domain/usecases/search_feed.dart';
import '../controller/feed_controller.dart';

/// GetX Binding for the Feed feature.
///
/// Injects all dependencies in the correct order:
/// 1. Core services (Dio, NetworkInfo, Cache)
/// 2. Data sources
/// 3. Repository
/// 4. Use cases
/// 5. Controller
///
/// All dependencies are lazily instantiated and properly scoped.
class FeedBinding extends Bindings {
  @override
  void dependencies() {
    // ── Core Services ──
    final dioClient = DioClient();

    // NetworkInfo — already registered as global service in main.dart
    final networkInfo = Get.find<NetworkInfo>();

    // SharedPreferences — already initialized in main.dart
    final prefs = Get.find<SharedPreferences>();
    final localCache = LocalCache(prefs);

    // ── Data Sources ──
    final productDS = ProductRemoteDataSource(dioClient);
    final postDS = PostRemoteDataSource(dioClient);

    // ── Repository ──
    final repository = FeedRepositoryImpl(
      productDS: productDS,
      postDS: postDS,
      dioClient: dioClient,
      localCache: localCache,
    );

    // ── Use Cases ──
    final fetchInitialFeed = FetchInitialFeed(repository);
    final fetchNextPage = FetchNextPage(repository);
    final searchFeed = SearchFeed(repository);

    // ── Controller ──
    Get.lazyPut<FeedController>(
      () => FeedController(
        fetchInitialFeed: fetchInitialFeed,
        fetchNextPage: fetchNextPage,
        searchFeed: searchFeed,
        repository: repository,
        networkInfo: networkInfo,
      ),
    );
  }
}
