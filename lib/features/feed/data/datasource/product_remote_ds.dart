import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/product_model.dart';

/// Remote data source for Products API.
///
/// Handles pagination, search, and CancelToken management
/// for the dummyjson.com/products endpoint.
class ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSource(this._dioClient);

  /// Fetches a page of products.
  ///
  /// [page] — 1-indexed page number
  /// [limit] — items per page (default: 10)
  /// [cancelToken] — for request cancellation
  Future<ProductsResponse> fetchProducts({
    required int page,
    int limit = ApiConstants.defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final skip = (page - 1) * limit;

    final response = await _dioClient.get(
      ApiConstants.products,
      queryParameters: {
        'limit': limit,
        'skip': skip,
        'select': ApiConstants.productFields,
      },
      cancelToken: cancelToken,
      deduplicationKey: 'products_page_$page',
    );

    final data = response.data as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final total = data['total'] as int? ?? 0;

    AppLogger.log(
      '📦 Fetched ${products.length} products (page: $page, total: $total)',
    );

    return ProductsResponse(
      products: products,
      total: total,
      skip: skip,
      limit: limit,
    );
  }

  /// Searches products by query string.
  Future<ProductsResponse> searchProducts({
    required String query,
    int limit = ApiConstants.searchResultLimit,
    CancelToken? cancelToken,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.productsSearch,
      queryParameters: {'q': query, 'limit': limit},
      cancelToken: cancelToken,
      deduplicationKey: 'products_search_$query',
    );

    final data = response.data as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final total = data['total'] as int? ?? 0;

    return ProductsResponse(
      products: products,
      total: total,
      skip: 0,
      limit: limit,
    );
  }
}

/// Response wrapper for products API
class ProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + products.length < total;
}
