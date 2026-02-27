import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Persistent local cache using SharedPreferences with TTL (Time To Live).
///
/// Used as Layer 2 cache for offline support.
/// Cache expiry: 5 minutes by default.
class LocalCache {
  static const Duration defaultExpiry = Duration(minutes: 5);
  static const String _feedCacheKey = 'cached_feed_data';
  static const String _feedTimestampKey = 'cached_feed_timestamp';

  final SharedPreferences _prefs;

  LocalCache(this._prefs);

  /// Saves feed data to persistent storage with current timestamp
  Future<void> saveFeedData(List<Map<String, dynamic>> feedJson) async {
    try {
      final jsonString = jsonEncode(feedJson);
      await _prefs.setString(_feedCacheKey, jsonString);
      await _prefs.setInt(
        _feedTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      AppLogger.log('💾 Feed data cached (${feedJson.length} items)');
    } catch (e) {
      AppLogger.logError('Failed to cache feed data', e);
    }
  }

  /// Retrieves cached feed data if it exists and hasn't expired.
  /// Returns null if no cache exists or cache has expired.
  List<Map<String, dynamic>>? getCachedFeedData({
    Duration expiry = defaultExpiry,
  }) {
    try {
      final timestamp = _prefs.getInt(_feedTimestampKey);
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cacheTime);

      // Check expiry — return null if stale
      if (age > expiry) {
        AppLogger.log(
          '⏰ Cache expired (age: ${age.inMinutes}m > ${expiry.inMinutes}m)',
        );
        return null;
      }

      final jsonString = _prefs.getString(_feedCacheKey);
      if (jsonString == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      AppLogger.log(
        '📦 Cache hit (age: ${age.inSeconds}s, ${decoded.length} items)',
      );
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.logError('Failed to read cached feed data', e);
      return null;
    }
  }

  /// Returns the age of the cached data, or null if no cache exists
  Duration? getCacheAge() {
    final timestamp = _prefs.getInt(_feedTimestampKey);
    if (timestamp == null) return null;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime);
  }

  /// Forces cache invalidation
  Future<void> clearCache() async {
    await _prefs.remove(_feedCacheKey);
    await _prefs.remove(_feedTimestampKey);
    AppLogger.log('🗑️ Cache cleared');
  }

  /// Check if valid (non-expired) cache exists
  bool hasValidCache({Duration expiry = defaultExpiry}) {
    final timestamp = _prefs.getInt(_feedTimestampKey);
    if (timestamp == null) return false;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) <= expiry;
  }
}
