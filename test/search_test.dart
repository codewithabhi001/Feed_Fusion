import 'package:flutter_test/flutter_test.dart';
import 'package:feed_fusion/core/network/dio_client.dart';
import 'package:feed_fusion/core/cache/local_cache.dart';
import 'package:feed_fusion/features/feed/data/datasource/product_remote_ds.dart';
import 'package:feed_fusion/features/feed/data/datasource/post_remote_ds.dart';
import 'package:feed_fusion/features/feed/data/repository_impl/feed_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Search API works', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dioClient = DioClient();
    final prodDs = ProductRemoteDataSource(dioClient);
    final postDs = PostRemoteDataSource(dioClient);
    final localCache = LocalCache(prefs);

    final repo = FeedRepositoryImpl(
      productDS: prodDs,
      postDS: postDs,
      dioClient: dioClient,
      localCache: localCache,
    );

    final items = await repo.search('phone');
    print('Found items: \${items.length}');
    expect(items.isNotEmpty, true);
  });
}
