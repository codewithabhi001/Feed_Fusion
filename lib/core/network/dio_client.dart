import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Singleton Dio HTTP client with interceptors, timeout configuration,
/// and CancelToken management for request cancellation.
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  // Active CancelTokens tracked by request group key
  final Map<String, CancelToken> _activeCancelTokens = {};

  // Request deduplication map — prevents duplicate in-flight requests
  final Map<String, Future<Response>> _activeRequests = {};

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Performance logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.logRequest(options.path, options.queryParameters);
          options.extra['requestStartTime'] =
              DateTime.now().millisecondsSinceEpoch;
          handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime =
              response.requestOptions.extra['requestStartTime'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            AppLogger.logResponseTime(response.requestOptions.path, duration);
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (error.type == DioExceptionType.cancel) {
            AppLogger.log('🚫 Request cancelled: ${error.requestOptions.path}');
          } else {
            AppLogger.logError(
              'API Error: ${error.requestOptions.path}',
              error,
              error.stackTrace,
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Factory constructor returns singleton instance
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Creates or retrieves a CancelToken for a given group key.
  /// Used to group related requests that should be cancelled together.
  CancelToken getCancelToken(String groupKey) {
    // Cancel any existing token for this group
    cancelGroup(groupKey);
    final token = CancelToken();
    _activeCancelTokens[groupKey] = token;
    return token;
  }

  /// Cancels all requests in a specific group
  void cancelGroup(String groupKey) {
    final token = _activeCancelTokens[groupKey];
    if (token != null && !token.isCancelled) {
      token.cancel('Request group "$groupKey" cancelled');
    }
    _activeCancelTokens.remove(groupKey);
    // Remove associated deduplication entries
    _activeRequests.removeWhere((key, _) => key.startsWith(groupKey));
  }

  /// Cancels ALL active requests — used during pull-to-refresh / new search
  void cancelAll() {
    for (final entry in _activeCancelTokens.entries) {
      if (!entry.value.isCancelled) {
        entry.value.cancel('All requests cancelled');
      }
    }
    _activeCancelTokens.clear();
    _activeRequests.clear();
  }

  /// Performs a GET request with deduplication.
  /// If an identical request is already in-flight, returns the same future
  /// instead of creating a duplicate network call.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? deduplicationKey,
  }) async {
    final dedupKey = deduplicationKey ?? '$path-$queryParameters';

    // Check for existing in-flight request (deduplication)
    if (_activeRequests.containsKey(dedupKey)) {
      AppLogger.log('⚡ Deduplication hit: $dedupKey');
      return _activeRequests[dedupKey]!;
    }

    // Create new request and store for deduplication
    final future = _dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    _activeRequests[dedupKey] = future;

    try {
      final response = await future;
      return response;
    } finally {
      _activeRequests.remove(dedupKey);
    }
  }
}
