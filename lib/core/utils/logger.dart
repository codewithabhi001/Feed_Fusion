import 'dart:developer' as dev;
import 'package:get/get.dart';

/// Centralized performance and debugging logger.
///
/// Logs API response times, merge operations, cache hits/misses,
/// and error traces for monitoring and debugging.
/// Now stores logs in memory for in-app viewing.
class AppLogger {
  static const String _tag = 'FeedFusion';

  /// In-memory log storage for UI display
  static final RxList<LogEntry> logs = <LogEntry>[].obs;

  static void _addLog(String message, {String type = 'INFO', dynamic error}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: type,
      error: error?.toString(),
    );
    logs.insert(0, entry);
    // Keep only last 100 logs
    if (logs.length > 100) logs.removeLast();
  }

  /// General purpose log
  static void log(String message) {
    dev.log(message, name: _tag);
    _addLog(message);
  }

  /// Log API request details
  static void logRequest(String path, Map<String, dynamic>? params) {
    final msg = '📡 Request: $path | Params: $params';
    dev.log(msg, name: _tag);
    _addLog(msg, type: 'REQUEST');
  }

  /// Log API response time for performance monitoring
  static void logResponseTime(String path, int durationMs) {
    final msg = '⏱️ Response: $path | ${durationMs}ms';
    dev.log(msg, name: _tag);
    _addLog(msg, type: 'PERF');
  }

  /// Log merge operation timing
  static void logMergeTime(int productCount, int postCount, int durationMs) {
    final msg =
        '🔀 Merge: $productCount products + $postCount posts | ${durationMs}ms';
    dev.log(msg, name: _tag);
    _addLog(msg, type: 'PERF');
  }

  /// Log errors with optional stack trace
  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    dev.log('❌ $message', name: _tag, error: error, stackTrace: stackTrace);
    _addLog(message, type: 'ERROR', error: error);
  }

  /// Log cache events
  static void logCache(String event, String key) {
    final msg = '💽 Cache $event: $key';
    dev.log(msg, name: _tag);
    _addLog(msg, type: 'CACHE');
  }

  /// Log pagination state
  static void logPagination({
    required int productPage,
    required int postPage,
    required int productCount,
    required int postCount,
  }) {
    final msg =
        '📄 Pagination | P: p=$productPage c=$productCount | Post: p=$postPage c=$postCount';
    dev.log(msg, name: _tag);
    _addLog(msg, type: 'PAGINATION');
  }
}

class LogEntry {
  final DateTime timestamp;
  final String message;
  final String type;
  final String? error;

  LogEntry({
    required this.timestamp,
    required this.message,
    required this.type,
    this.error,
  });
}
