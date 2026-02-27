import 'dart:collection';

/// Generic In-Memory LRU (Least Recently Used) Cache.
///
/// Provides O(1) get/put operations with automatic eviction
/// of least recently used entries when capacity is exceeded.
///
/// Usage:
/// ```dart
/// final cache = LruCache<String, dynamic>(maxSize: 100);
/// cache.put('key', value);
/// final cached = cache.get('key');
/// ```
class LruCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, _CacheEntry<V>> _map = LinkedHashMap();

  LruCache({this.maxSize = 50});

  /// Retrieves a value from cache.
  /// Returns null if key doesn't exist or entry has expired.
  V? get(K key) {
    final entry = _map[key];
    if (entry == null) return null;

    // Check TTL expiry if set
    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _map.remove(key);
      return null;
    }

    // Move to end (most recently used)
    _map.remove(key);
    _map[key] = entry;
    return entry.value;
  }

  /// Stores a value in the cache with optional TTL.
  void put(K key, V value, {Duration? ttl}) {
    // Remove existing entry to update position
    _map.remove(key);

    // Evict LRU entry if at capacity
    if (_map.length >= maxSize) {
      _map.remove(_map.keys.first);
    }

    _map[key] = _CacheEntry(
      value: value,
      expiry: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }

  /// Checks if key exists and is not expired
  bool containsKey(K key) {
    final entry = _map[key];
    if (entry == null) return false;
    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _map.remove(key);
      return false;
    }
    return true;
  }

  /// Removes a specific key
  void remove(K key) => _map.remove(key);

  /// Clears all entries
  void clear() => _map.clear();

  /// Current number of entries
  int get length => _map.length;

  /// Whether the cache is empty
  bool get isEmpty => _map.isEmpty;
}

/// Internal cache entry wrapper with optional expiry
class _CacheEntry<V> {
  final V value;
  final DateTime? expiry;

  _CacheEntry({required this.value, this.expiry});
}
